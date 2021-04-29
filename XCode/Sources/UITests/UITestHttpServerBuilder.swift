import Foundation
import Swifter
import XCTest

public typealias EndpointDataResponse = (endpoint: String, statusCode: Int, body: Data, responseTime: UInt32?)
public typealias DataReponse = (statusCode: Int, body: Data, responseTime: UInt32?)

public class UITestHttpServerBuilder {
    public static let httpLocalhost = "http://127.0.0.1"
    public private(set) var httpServer: HttpServer = HttpServer()

    public init() {}

    private struct EDResponse {
        let endpoint: String
        let statusCode: Int
        let body: Data
        let responseTime: UInt32?
        let onReceivedHttpRequest: ((Swifter.HttpRequest) -> Void)?
    }

    private struct ECallBackResponse {
        let endpoint: String
        let callBack: (Swifter.HttpRequest) -> HttpResponse
    }

    private let uncallqQueue = DispatchQueue(label: "queue.endpoint.uncalled")
    private var httpResponses: [EDResponse] = []
    private var httpCallBackResponses: [ECallBackResponse] = []
    private var imagesResponse: [ImageReponse] = []

    private var endpointCallCount: [String: Int] = [:]

    public func route(_ responses: [EndpointDataResponse]) -> UITestHttpServerBuilder {
        responses.forEach { response in
            _ = route(response)
        }
        return self
    }

    public func routeImagesAt(path: String, properties: ((Swifter.HttpRequest) -> ImageProperties)? = nil) {
        imagesResponse.append(ImageReponse(path: path, properties: properties))
    }

    public func route(_ response: EndpointDataResponse, on: ((Swifter.HttpRequest) -> Void)? = nil) -> UITestHttpServerBuilder {
        httpResponses.append(EDResponse(endpoint: response.endpoint,
                                        statusCode: response.statusCode,
                                        body: response.body,
                                        responseTime: response.responseTime,
                                        onReceivedHttpRequest: on))
        return self
    }

    public func route(endpoint: String, on: @escaping ((Swifter.HttpRequest) -> HttpResponse)) -> UITestHttpServerBuilder {
        httpCallBackResponses.append(ECallBackResponse(endpoint: endpoint, callBack: on))
        return self
    }

    private func updateEndpointCallCount(_ endpoint: String) {
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
            let groupByEndpoint = Dictionary(grouping: httpResponses, by: { $0.endpoint })
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
            return "Endpoint: \(edResponse.endpoint)\n" + "\(String(describing: String(bytes: edResponse.body, encoding: .utf8)))"
        }
    }

    func buildImageResponses() {
        imagesResponse.forEach { (imageResponse) in
            httpServer[imageResponse.path] = { request in
                Logger.info("Request image: \(request.path)")
                let data: Data
                if let imageProperties = imageResponse.properties {
                    let properties = imageProperties(request)
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
        let groupByEndpoint = Dictionary(grouping: httpResponses) { $0.endpoint }
        for (endpoint, responses) in groupByEndpoint {
            let queue = DispatchQueue(label: "queue.endpoint.\(endpoint)")
            var index = 0
            Logger.info("Building endpoint: \(endpoint) Response.count:\(responses.count)")
            httpServer[endpoint] = { request in
                Logger.info("Handled request path:\(request.path) Params:\(request.queryParams) Response.count:\(responses.count)")
                var response: EDResponse!
                self.updateEndpointCallCount(endpoint)
                queue.sync {
                    index = index < responses.count ? index : 0
                    response = responses[index]
                    index = index + 1
                }
                if let onReceivedHttpRequest = response.onReceivedHttpRequest {
                    DispatchQueue.main.sync {
                        onReceivedHttpRequest(request)
                    }
                }
                sleep(response.responseTime ?? 0)
                return HttpResponse.raw(statusCode: response.statusCode, body: response.body)
            }
        }

        for endpointCallBackResponse in httpCallBackResponses {
            httpServer[endpointCallBackResponse.endpoint] = { request in
                self.updateEndpointCallCount(endpointCallBackResponse.endpoint)
                return endpointCallBackResponse.callBack(request)
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
        public let endpoint: String
        // associated response count
        public let responseCount: Int
        // received http requests count
        public let httpRequestCount: Int

        public init(endpoint: String, responseCount: Int, httpRequestCount: Int) {
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
