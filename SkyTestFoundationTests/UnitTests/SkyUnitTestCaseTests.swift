import XCTest
import Swifter
@testable import SkyTestFoundation

class SkyUnitTestCaseTests: SkyUnitTestCase {

    func testSetup() {
        XCTAssertNotNil(httpServerBuilder)
        XCTAssertEqual(httpServerBuilder.httpServer.routes.count, 0)
    }

    func testExampleTemplate00() throws {
        let exp = expectation(description: "")
        try httpServerBuilder
            .route("/login") { (_, _) -> (HttpResponse) in
                exp.fulfill()
                return HttpResponse.ok(HttpResponseBody.data(Data()))
            }
            .buildAndStart()
        let url = URL(string: "http://localhost:8080/login")!
        let session = URLSession(configuration: URLSessionConfiguration.default)
        session.dataTask(with: url).resume()
        waitForExpectations(timeout: 3) { (error) in
            print("Error:\(String(describing: error))")
        }
    }


    func testStressRouteCallCount() throws {
        for _ in 1...20 {
            super.setUp()
            try _testRouteCallCount()
            super.tearDown()
        }
    }

    func _testRouteCallCount() throws {
        let exp = expectation(description: "..")
        try httpServerBuilder
            .route("login") { (_, callCount) -> (HttpResponse) in
                XCTAssertLessThanOrEqual(callCount, 2)
                if callCount == 2 {
                    exp.fulfill()
                }
                return HttpResponse.ok(HttpResponseBody.data(Data()))
            }
            .buildAndStart()

        let url = URL(string: "http://localhost:8080/login")!
        let session = URLSession(configuration: .default)
        let dataTask00 = session.dataTask(with: URLRequest(url: url))
        let dataTask01 = session.dataTask(with: URLRequest(url: url))
        dataTask00.resume()
        dataTask01.resume()

        waitForExpectations(timeout: 3)
        dataTask00.cancel()
        dataTask01.cancel()
    }
}
