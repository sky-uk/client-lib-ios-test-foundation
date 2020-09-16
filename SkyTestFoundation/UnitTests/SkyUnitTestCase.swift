import Swifter
import Foundation
import XCTest

class SkyUnitTestCase: XCTestCase {
    var httpServerBuilder: UTHttpServerBuilder! = UTHttpServerBuilder()

    override func setUp() {
        super.setUp()
        httpServerBuilder.httpServer.stop()
        httpServerBuilder = UTHttpServerBuilder()
    }

    override func tearDown() {
        httpServerBuilder.httpServer.stop()
        super.tearDown()
    }
}

extension HttpResponse {
    static func ok(_ data: Data) -> HttpResponse {
        return HttpResponse.ok(HttpResponseBody.data(data))
    }
}

extension HttpRequest {

    func header(name: String) -> String? {
        return self.headers[name]
    }

    func queryParam(name: String) -> String? {
        return self.queryParams.first { (tupla) -> Bool in
            return tupla.0 == name
            }?.1
    }
}
