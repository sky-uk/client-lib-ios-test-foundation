import XCTest
import Swifter
@testable import SkyTestFoundation

class UTHttpServerBuilderTests: XCTestCase {

    func testBuildAndRun() throws {
        XCTAssertNotNil(try UTHttpServerBuilder().buildAndStart())
    }

    func testRoute() throws {
        let exp = expectation(description: "")
        let httpServerBuilder = UTHttpServerBuilder()
        try httpServerBuilder
            .route("login") { (request, callCount) -> (HttpResponse) in
                XCTAssertEqual(callCount, 1)
                XCTAssertEqual(request.path, "/login")
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

    func testRouteCallCount() throws {
        let exp = expectation(description: "")
        let httpServerBuilder = UTHttpServerBuilder()
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
