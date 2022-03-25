import Foundation
import Swifter
import XCTest

public typealias DataReponse = (statusCode: Int, body: Data, delay: UInt32?)

public class UITestHttpServerBuilder {
    public static let httpLocalhost = "http://127.0.0.1"
    public private(set) var httpServer: HttpServer = HttpServer()

    public init() {}

    private struct EDResponse {
        let endpoint: HttpEndpoint
        let statusCode: Int
        let body: Data
        let headers: [String: String]
        let sleepDelay: UInt32?
        let onReceivedHttpRequest: ((HttpRequest) -> Void)?
    }

    private struct ECallBackResponse {
        let endpoint: HttpEndpoint
        let callBack: (HttpRequest) -> HttpResponse
    }
    private let updateCallCountSemaphore = DispatchSemaphore(value: 1)
    private let updateCallCountQueue = DispatchQueue(label: "queue.endpoint.uncalled")
    private var httpResponses: [EDResponse] = []
    private var httpCallBackResponses: [ECallBackResponse] = []
    private var imagesResponse: [ImageReponse] = []

    private var endpointCallCount: [HttpEndpoint: Int] = [:]

    public func route(_ routes: [HttpRoute]) -> UITestHttpServerBuilder {
        routes.forEach { response in
            _ = route(response)
        }
        return self
    }

    @discardableResult
    public func routeImagesAt(path: String, properties: ((HttpRequest) -> ImageProperties)? = nil) -> UITestHttpServerBuilder {
        imagesResponse.append(ImageReponse(path: path, properties: properties))
        return self
    }

    public func route(_ route: HttpRoute, on: ((HttpRequest) -> Void)? = nil) -> UITestHttpServerBuilder {
        httpResponses.append(EDResponse(endpoint: route.endpoint,
                                        statusCode: route.response.statusCode,
                                        body: route.response.body,
                                        headers: route.response.headers,
                                        sleepDelay: route.sleepDelay,
                                        onReceivedHttpRequest: on))
        return self
    }

    public func route(endpoint: HttpEndpoint, on: @escaping ((HttpRequest) -> HttpResponse)) -> UITestHttpServerBuilder {
        httpCallBackResponses.append(ECallBackResponse(endpoint: endpoint, callBack: on))
        return self
    }


    public func undefinedRoute(_ asserts: @escaping (HttpRequest) -> Void) -> UITestHttpServerBuilder {
        httpServer.notFoundHandler = { request in
            Logger.info("NOT handled: \(request.method) \(request.path) Params:\(request.queryParams)")
            DispatchQueue.main.sync {
                asserts(request.httpRequest())
            }
            return HttpResponse.notFound().toSwifter()
        }
        return self
    }


    private func updateEndpointCallCount(_ endpoint: HttpEndpoint) {
        updateCallCountQueue.async {
            self.updateCallCountSemaphore.wait()
            let callCount: Int
            if let count = self.endpointCallCount[endpoint] {
                callCount = count + 1
            } else {
                callCount = 1
            }
            self.endpointCallCount[endpoint] = callCount
            self.updateCallCountSemaphore.signal()
        }
    }

    public func callReport() -> [EndpointReport] {
        updateCallCountQueue.sync {
            self.updateCallCountSemaphore.wait()
            let groupByEndpoint = Dictionary(grouping: httpResponses, by: { $0.endpoint })
            let expectedReports: [EndpointReport] = groupByEndpoint.keys.map {
                let responseCount = groupByEndpoint[$0]?.count ?? 0
                return EndpointReport(endpoint: $0, responseCount: responseCount, httpRequestCount: 0)
            }
            self.updateCallCountSemaphore.signal()
            return expectedReports.map {
                $0.edited(receivedCallCount: endpointCallCount[$0.endpoint] ?? 0)
            }

        }
    }

    public func definedResponses() -> [String] {
        return self.httpResponses.map { (edResponse) -> String in
            return "Endpoint: \(edResponse.endpoint)\n" + "\(String(describing: String(bytes: edResponse.body, encoding: .utf8)))"
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
                return HttpResponse(body: data, statusCode: 200).toSwifter()
            }
        }
    }

    @discardableResult
    public func buildAndStart(port: in_port_t = 8080, file: StaticString = #file, line: UInt = #line) -> HttpServer {
        buildImageResponses()
        let groupByEndpoint = Dictionary(grouping: httpResponses) { $0.endpoint }
        for (endpoint, responses) in groupByEndpoint {
            let queue = DispatchQueue(label: "queue.endpoint.\(endpoint)")
            var index = 0
            Logger.info("Building endpoint: \(endpoint) Response.count:\(responses.count)")
            httpServer.buildRoute(endpoint) { request in
                var response: EDResponse!
                self.updateEndpointCallCount(endpoint)
                queue.sync {
                    index = index < responses.count ? index : 0
                    response = responses[index]
                    index = index + 1
                }
                Logger.info("Handled request:\(request.method) \(request.path) Query params:\(request.queryParams) Response statusCode: \(response.statusCode) Response.count:\(responses.count)")
                if let onReceivedHttpRequest = response.onReceivedHttpRequest {
                    DispatchQueue.main.sync {
                        onReceivedHttpRequest(request.httpRequest())
                    }
                }
                sleep(response.sleepDelay ?? 0)
                return HttpResponse(body: response.body, statusCode: response.statusCode,  headers: response.headers).toSwifter()
            }
        }

        for endpointCallBackResponse in httpCallBackResponses {
            Logger.info("Building endpoint: \(endpointCallBackResponse.endpoint)")
            httpServer.buildRoute(endpointCallBackResponse.endpoint) { request in
                Logger.info("Handled request:\(request.method) \(request.path) Params:\(request.queryParams)")
                self.updateEndpointCallCount(endpointCallBackResponse.endpoint)
                return endpointCallBackResponse.callBack(request.httpRequest()).toSwifter()
            }
        }

        if httpServer.notFoundHandler == nil {
            httpServer.notFoundHandler = { request in
                Logger.info("NOT handled: \(request.method) \(request.path) Params:\(request.queryParams)")
                return HttpResponse.notFound().toSwifter()
            }
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
        public let endpoint: HttpEndpoint
        // associated response count
        public let responseCount: Int
        // received http requests count
        public let httpRequestCount: Int

        public init(endpoint: HttpEndpoint, responseCount: Int, httpRequestCount: Int) {
            self.endpoint = endpoint
            self.responseCount = responseCount
            self.httpRequestCount = httpRequestCount
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

    func buildRoute(_ endpoint: HttpEndpoint, body: ((Swifter.HttpRequest) -> Swifter.HttpResponse)?) {
        switch endpoint.method {
            case .delete:
                return self.DELETE[endpoint.path] = body
            case .get:
                return self.GET[endpoint.path] = body
            case .head:
                return self.HEAD[endpoint.path] = body
            case .patch:
                return self.PATCH[endpoint.path] = body
            case .post:
                return self.POST[endpoint.path] = body
            case .put:
                return self.PUT[endpoint.path] = body
        }
    }
}
