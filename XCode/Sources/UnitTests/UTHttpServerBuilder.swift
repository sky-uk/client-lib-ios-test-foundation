import Foundation
import Swifter
import XCTest

public class UTHttpServerBuilder {
    public private(set) var httpServer: HttpServer = HttpServer()
    public var httpRoutes: [Route] = []

    public func route(_ endpoint: String, _ completion: @escaping (HttpRequest, Int) -> (HttpResponse)) -> UTHttpServerBuilder {
        let lock = DispatchSemaphore(value: 1)
        var callCount = 0
        httpServer.self[endpoint] = { request in
            lock.wait()
            callCount += 1
            lock.signal()
            return completion(request.httpRequest(), callCount)
        }
        return self
    }

    public func onUnexpected(_ asserts: @escaping (HttpRequest) -> Void) -> UTHttpServerBuilder {
        httpServer.notFoundHandler = { request in
            DispatchQueue.main.sync {
                asserts(request.httpRequest())
            }
            return HttpResponse.badRequest(HttpResponseBody.html(""))
        }
        return self
    }

    @discardableResult
    public func buildAndStart(port: in_port_t = 8080, forceIPv4: Bool = false, priority: DispatchQoS.QoSClass = .userInteractive) -> HttpServer {
        httpRoutes.forEach { (route) in
            buildRoute(endpoint: route.enpoint, completion: route.completion)
        }
        do {
            try httpServer.start(port, forceIPv4: forceIPv4, priority: priority)
        } catch {
            XCTFail("\(error)")
        }
        return httpServer
    }

    private func buildRoute(endpoint: String, completion: @escaping (HttpRequest, Int) -> (HttpResponse)) {
        let lock = DispatchSemaphore(value: 1)
        var callCount = 0
        httpServer.self[endpoint] = { request in
            lock.wait()
            callCount += 1
            lock.signal()
            return completion(request.httpRequest(), callCount)
        }
    }

    public struct Route {
        let enpoint: String
        let completion: (HttpRequest, Int) -> (HttpResponse)
    }
}
