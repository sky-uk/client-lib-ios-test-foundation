import XCTest
import Swifter
@testable import SkyTestFoundation

class SkyUnitTestCaseTests: SkyUnitTestCase {

    func testSetup() {
        XCTAssertNotNil(httpServerBuilder)
        XCTAssertEqual(httpServerBuilder.httpServer.routes.count, 0)
    }

    func testOneEndpoint() throws {
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

    func testWithTwoEndpoint() throws {
        let exp00 = expectation(description: "expectation 00")
        let exp01 = expectation(description: "expectation 01")

        try httpServerBuilder
            .route("/endpoint00") { (_, _) -> (HttpResponse) in
                exp00.fulfill()
                return HttpResponse.ok(HttpResponseBody.data(Data()))
            }
            .route("/endpoint01", { (_, _) -> (HttpResponse) in
                exp01.fulfill()
                return HttpResponse.ok(HttpResponseBody.data(Data()))
            })
            .buildAndStart()

        let session = URLSession(configuration: URLSessionConfiguration.default)

        let url00 = URL(string: "http://localhost:8080/endpoint00")!
        session.dataTask(with: url00).resume()

        let url01 = URL(string: "http://localhost:8080/endpoint01")!
        session.dataTask(with: url01).resume()

        wait(for: [exp00, exp01], timeout: 3)
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
