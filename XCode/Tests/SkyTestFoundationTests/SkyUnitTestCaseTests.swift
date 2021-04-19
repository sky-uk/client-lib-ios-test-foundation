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
        httpServerBuilder
            .route("/login") { (_, _) -> (HttpResponse) in
                return HttpResponse.ok(HttpResponseBody.data(Data()))
            }
            .buildAndStart()
        let url = URL(string: "http://localhost:8080/login")!
        let session = URLSession(configuration: URLSessionConfiguration.default)
        session.dataTask(with: url, completionHandler: { (_, _, error) in
            XCTAssertNil(error)
            exp.fulfill()
        }).resume()
        waitForExpectations(timeout: 3) { (error) in
            print("Error:\(String(describing: error))")
        }
    }

    func testWithTwoEndpoint() throws {
        let exp00 = expectation(description: "expectation 00")
        let exp01 = expectation(description: "expectation 01")

        httpServerBuilder
            .route("/endpoint00") { (_, _) -> (HttpResponse) in
                return HttpResponse.ok(HttpResponseBody.data(Data()))
            }
            .route("/endpoint01", { (_, _) -> (HttpResponse) in
                return HttpResponse.ok(HttpResponseBody.data(Data()))
            })
            .buildAndStart()

        let session = URLSession(configuration: URLSessionConfiguration.default)

        let url00 = URL(string: "http://localhost:8080/endpoint00")!
        let dataTask00 = session.dataTask(with: url00) { (_, _, error) in
            XCTAssertNil(error)
            exp00.fulfill()
        }

        let url01 = URL(string: "http://localhost:8080/endpoint01")!
        let dataTask01 = session.dataTask(with: url01) { (_, _, error) in
            XCTAssertNil(error)
            exp01.fulfill()
        }
        dataTask00.resume()
        dataTask01.resume()
        wait(for: [exp00, exp01], timeout: 3)
    }

    func testUnexpectedHttpCall() throws {
        let exp00 = expectation(description: "expectation 00")
        let exp01 = expectation(description: "expectation 01")
        let exp02 = expectation(description: "expectation 02")

        httpServerBuilder
            .route("/endpoint00") { (_, _) -> (HttpResponse) in
                return HttpResponse.ok(HttpResponseBody.data(Data()))
            }
            .onUnexpected { _ in
                exp01.fulfill() // "Unexpected request.path
            }
            .buildAndStart()

        let session = URLSession(configuration: URLSessionConfiguration.default)

        let url00 = URL(string: "http://localhost:8080/endpoint00")!
        let dataTask00 = session.dataTask(with: url00) { (_, _, error) in
            XCTAssertNil(error)
            exp00.fulfill()
        }

        let url01 = URL(string: "http://localhost:8080/endpoint01")!
        let dataTask01 = session.dataTask(with: url01) { (_, _, error) in
            XCTAssertNil(error)
            exp02.fulfill()
        }

        dataTask00.resume()
        dataTask01.resume()
        wait(for: [exp00, exp01, exp02], timeout: 3)
    }

    func testStressRouteCallCount() throws {
        for _ in 1...20 {
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
        httpServerBuilder
            .route("login") { (_, _) -> (HttpResponse) in
                return HttpResponse.ok(HttpResponseBody.data(Data()))
            }
            .buildAndStart()

        let url = URL(string: "http://localhost:8080/login")!
        let session = URLSession(configuration: .default)
        let dataTask00 = session.dataTask(with: url) { (_, _, error) in
            XCTAssertNil(error)
            exp.fulfill()
        }
        dataTask00.resume()
        wait(for: [exp], timeout: 3)
    }
}
