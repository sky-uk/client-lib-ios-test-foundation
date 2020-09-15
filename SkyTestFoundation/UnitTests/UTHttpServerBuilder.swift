import Foundation
import Swifter

class UTHttpServerBuilder {
    public private(set) var httpServer: HttpServer = HttpServer()
    public var httpRoutes: [Route] = []

    func route(_ endpoint: String, _ completion: @escaping (HttpRequest, Int) -> (HttpResponse)) -> UTHttpServerBuilder {
        let lock = DispatchSemaphore(value: 1)
        var callCount = 0
        httpServer.self[endpoint] = { request in
            lock.wait()
            callCount += 1
            lock.signal()
            return completion(request, callCount)
        }
        return self
    }

    @discardableResult
    func buildAndStart(port: in_port_t = 8080, forceIPv4: Bool = false) throws -> HttpServer {
        httpRoutes.forEach { (route) in
            buildRoute(endpoint: route.enpoint, completion: route.completion)
        }
        try httpServer.start(port, forceIPv4: forceIPv4)
        return httpServer
    }

    private func buildRoute(endpoint: String, completion: @escaping (HttpRequest, Int) -> (HttpResponse)) {
        let lock = DispatchSemaphore(value: 1)
        var callCount = 0
        httpServer.self[endpoint] = { request in
            lock.wait()
            callCount += 1
            lock.signal()
            return completion(request, callCount)
        }
    }

    struct Route {
        let enpoint: String
        let completion: (HttpRequest, Int) -> (HttpResponse)
    }
}
