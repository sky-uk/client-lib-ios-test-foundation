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
        let dataTask00 = session.dataTask(with: url00)

        let url01 = URL(string: "http://localhost:8080/endpoint01")!
        let dataTask01 = session.dataTask(with: url01)

        dataTask00.resume()
        dataTask01.resume()
        wait(for: [exp00, exp01], timeout: 3)
        dataTask00.cancel()
        dataTask01.cancel()
    }

    func testUnexpectedHttpCall() throws {
        let exp00 = expectation(description: "expectation 00")
        let exp01 = expectation(description: "expectation 01")

        try httpServerBuilder
            .route("/endpoint00") { (_, _) -> (HttpResponse) in
                exp00.fulfill()
                return HttpResponse.ok(HttpResponseBody.data(Data()))
            }
            .onUnexpected { request in
                exp01.fulfill() // "Unexpected request.path
            }
            .buildAndStart()

        let session = URLSession(configuration: URLSessionConfiguration.default)

        let url00 = URL(string: "http://localhost:8080/endpoint00")!
        let dataTask00 = session.dataTask(with: url00)

        let url01 = URL(string: "http://localhost:8080/endpoint01")!
        let dataTask01 = session.dataTask(with: url01)

        dataTask00.resume()
        dataTask01.resume()
        wait(for: [exp00, exp01], timeout: 3)
        dataTask00.cancel()
        dataTask01.cancel()
    }

    func testStressRouteCallCount() throws {
        for _ in 1...5 {
            super.setUp()
            try _testRouteCallCount()
            super.tearDown()
        }
    }

    func _testRouteCallCount() throws {
        enum CounterLock {
            case waiting, reached, signalled
        }
        let exp = expectation(description: "..")
        var lock : CounterLock = .waiting
        try httpServerBuilder
            .route("login") { (_, callCount) -> (HttpResponse) in
                XCTAssertLessThanOrEqual(callCount, 2)
                if callCount == 2 {
                    lock = .reached
                }
                return HttpResponse.ok(HttpResponseBody.data(Data()))
            }
            .buildAndStart()

        let url = URL(string: "http://localhost:8080/login")!
        let session = URLSession(configuration: .default)
        let completionHandler : (Data?, URLResponse?, Error?) -> Void = { (data, response, error) in
            switch lock {
                case .reached:
                    exp.fulfill()
                    lock = .signalled
                default:
                    break
            }
        }
        let dataTask00 = session.dataTask(with: URLRequest(url: url), completionHandler: completionHandler)
        let dataTask01 = session.dataTask(with: URLRequest(url: url), completionHandler: completionHandler)
        dataTask00.resume()
        dataTask01.resume()
        waitForExpectations(timeout: 3)
        dataTask00.cancel()
        dataTask00.cancel()
    }
}
