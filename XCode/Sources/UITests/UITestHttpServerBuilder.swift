import Foundation
import Swifter
import XCTest

public typealias EndpointDataResponse = (route: HttpRoute, statusCode: Int, body: Data, responseTime: UInt32?)
public typealias DataReponse = (statusCode: Int, body: Data, responseTime: UInt32?)

public class UITestHttpServerBuilder {
    public static let httpLocalhost = "http://127.0.0.1"
    public private(set) var httpServer: HttpServer = HttpServer()

    public init() {}

    private struct EDResponse {
        let route: HttpRoute
        let statusCode: Int
        let body: Data
        let responseTime: UInt32?
        let onReceivedHttpRequest: ((HttpRequest) -> Void)?
    }

    private struct ECallBackResponse {
        let endpoint: HttpRoute
        let callBack: (HttpRequest) -> HttpResponse
    }

    private let uncallqQueue = DispatchQueue(label: "queue.endpoint.uncalled")
    private var httpResponses: [EDResponse] = []
    private var httpCallBackResponses: [ECallBackResponse] = []
    private var imagesResponse: [ImageReponse] = []

    private var endpointCallCount: [HttpRoute: Int] = [:]

    public func route(_ responses: [EndpointDataResponse]) -> UITestHttpServerBuilder {
        responses.forEach { response in
            _ = route(response)
        }
        return self
    }

    public func routeImagesAt(path: String, properties: ((HttpRequest) -> ImageProperties)? = nil) {
        imagesResponse.append(ImageReponse(path: path, properties: properties))
    }

    public func route(_ response: EndpointDataResponse, on: ((HttpRequest) -> Void)? = nil) -> UITestHttpServerBuilder {
        httpResponses.append(EDResponse(route: response.route,
                                        statusCode: response.statusCode,
                                        body: response.body,
                                        responseTime: response.responseTime,
                                        onReceivedHttpRequest: on))
        return self
    }

    public func route(endpoint: HttpRoute, on: @escaping ((HttpRequest) -> HttpResponse)) -> UITestHttpServerBuilder {
        httpCallBackResponses.append(ECallBackResponse(endpoint: endpoint, callBack: on))
        return self
    }

    private func updateEndpointCallCount(_ endpoint: HttpRoute) {
        uncallqQueue.async {
            let callCount: Int
            if let count = self.endpointCallCount[endpoint] {
                callCount = count + 1
            } else {
                callCount = 1
            }
            self.endpointCallCount[endpoint] = callCount
        }
    }

    public func callReport() -> [EndpointReport] {
        uncallqQueue.sync {
            let groupByEndpoint = Dictionary(grouping: httpResponses, by: { $0.route })
            let expectedReports: [EndpointReport] = groupByEndpoint.keys.map {
                let responseCount = groupByEndpoint[$0]?.count ?? 0
                return EndpointReport(endpoint: $0, responseCount: responseCount, httpRequestCount: 0)
            }
            return expectedReports.map {
                $0.edited(receivedCallCount: endpointCallCount[$0.endpoint] ?? 0)
            }
        }
    }

    public func definedResponses() -> [String] {
        return self.httpResponses.map { (edResponse) -> String in
            return "Endpoint: \(edResponse.route)\n" + "\(String(describing: String(bytes: edResponse.body, encoding: .utf8)))"
        }
    }

    func buildImageResponses() {
        imagesResponse.forEach { (imageResponse) in
            httpServer[imageResponse.path] = { request in
                Logger.info("Request image: \(request.path)")
                let data: Data
                if let imageProperties = imageResponse.properties {
                    let properties = imageProperties(request.httpRequest())
                    data = UITestHttpServerBuilder.drawOnImage(text: request.path, properties: properties)
                } else {
                    data = UITestHttpServerBuilder.drawOnImage(text: request.path)
                }
                return HttpResponse.raw(200, "", nil) { (writer) in
                    try writer.write(data)
                }
            }
        }
    }

    @discardableResult
    public func buildAndStart(port: in_port_t = 8080, file: StaticString = #file, line: UInt = #line) -> HttpServer {
        buildImageResponses()
        let groupByEndpoint = Dictionary(grouping: httpResponses) { $0.route }
        for (endpoint, responses) in groupByEndpoint {
            let queue = DispatchQueue(label: "queue.endpoint.\(endpoint)")
            var index = 0
            Logger.info("Building endpoint: \(endpoint) Response.count:\(responses.count)")
            httpServer.buildRoute(endpoint) { request in
                Logger.info("Handled request:\(request.method) \(request.path) Params:\(request.queryParams) Response.count:\(responses.count)")
                var response: EDResponse!
                self.updateEndpointCallCount(endpoint)
                queue.sync {
                    index = index < responses.count ? index : 0
                    response = responses[index]
                    index = index + 1
                }
                if let onReceivedHttpRequest = response.onReceivedHttpRequest {
                    DispatchQueue.main.sync {
                        onReceivedHttpRequest(request.httpRequest())
                    }
                }
                sleep(response.responseTime ?? 0)
                return HttpResponse.raw(statusCode: response.statusCode, body: response.body)
            }
        }

        for endpointCallBackResponse in httpCallBackResponses {
            httpServer.buildRoute(endpointCallBackResponse.endpoint) { request in
                Logger.info("Handled request:\(request.method) \(request.path) Params:\(request.queryParams)")
                self.updateEndpointCallCount(endpointCallBackResponse.endpoint)
                return endpointCallBackResponse.callBack(request.httpRequest())
            }
        }

        httpServer.notFoundHandler = { request in
            Logger.info("NOT handled request path: \(request.path) Params:\(request.queryParams)")
            return HttpResponse.notFound
        }

        Logger.info("Starting  server [port=\(port)]")
        do {
            try httpServer.start(port)
        } catch {
            XCTFail("\(error)")
        }
        return httpServer
    }

    public struct EndpointReport {
        // endpoint
        public let endpoint: HttpRoute
        // associated response count
        public let responseCount: Int
        // received http requests count
        public let httpRequestCount: Int

        public init(endpoint: HttpRoute, responseCount: Int, httpRequestCount: Int) {
            self.endpoint = endpoint
            self.responseCount = responseCount
            self.httpRequestCount = httpRequestCount
        }
    }
}

public extension HttpResponse {
    static func raw(statusCode: Int, body: Data) -> HttpResponse {
        return HttpResponse.raw(statusCode, "", nil) { (writer) in
            try writer.write(body)
        }
    }
}

// Hosting application see only type of this framework
extension Swifter.HttpRequest {
    func httpRequest() -> HttpRequest {
        ConcreteHttpRequest(
            path: path,
            method: method,
            body: body,
            address: address,
            headers: headers,
            params: params,
            queryParams: queryParams
        )
    }
}

private struct ConcreteHttpRequest: HttpRequest {
    var path: String
    var method: String
    var body: [UInt8]
    var address: String?
    var headers: [String: String]
    var params: [String: String]
    var queryParams: [(String, String)]
}

extension Swifter.HttpServer {

    func buildRoute(_ route: HttpRoute, body: ((Swifter.HttpRequest) -> HttpResponse)?) {
        switch route.method {
            case .delete:
                return self.DELETE[route.path] = body
            case .get:
                return self.GET[route.path] = body
            case .head:
                return self.HEAD[route.path] = body
            case .patch:
                return self.PATCH[route.path] = body
            case .post:
                return self.POST[route.path] = body
            case .put:
                return self.PUT[route.path] = body
        }
    }
}
