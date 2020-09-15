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
        URLSession.shared.dataTask(with: URLRequest(url: url)).resume()
        waitForExpectations(timeout: 3) { (error) in
            print("\(String(describing: error))")
        }
    }

    func testExampleTemplate01() throws {
        let exp00 = expectation(description: "")
        let exp01 = expectation(description: "")

        try httpServerBuilder
            .route("/login") { (_, _) -> (HttpResponse) in
                exp00.fulfill()
                return HttpResponse.ok(HttpResponseBody.data(Data()))
            }
            .route("/events", { (_, _) -> (HttpResponse) in
                exp01.fulfill()
                return HttpResponse.ok(HttpResponseBody.data(Data()))
            })
            .buildAndStart()

        URLSession.shared.dataTask(with: URLRequest(url: URL(string: "http://localhost:8080/login")!)).resume()
        URLSession.shared.dataTask(with: URLRequest(url: URL(string: "http://localhost:8080/events")!)).resume()

        wait(for: [exp00, exp01], timeout: 3)
    }


     func testStressTests() throws {
           for _ in 1...1000 {
               super.setUp()
               try _testRouteCallCount()
               super.tearDown()
           }
       }

    func _testRouteCallCount() throws {
        let exp = expectation(description: "")
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
        URLSession.shared.dataTask(with: URLRequest(url: url)).resume()
        URLSession.shared.dataTask(with: URLRequest(url: url)).resume()

        waitForExpectations(timeout: 3) { (error) in
            print("\(String(describing: error))")
        }
    }

}
