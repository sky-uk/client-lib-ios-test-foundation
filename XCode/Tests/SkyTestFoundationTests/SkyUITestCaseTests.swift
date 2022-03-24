import Foundation
import XCTest
@testable import SkyTestFoundation

class SkyUITestCaseTests: SkyUITestCase {

    func testSetup() {
        XCTAssertNotNil(httpServerBuilder)
        XCTAssertEqual(httpServerBuilder.httpServer.routes.count, 0)
    }

    func testOneEndpoint() throws {
        let httpResponse = HttpResponse(body: "xyz".data(using: .ascii)!)
        let exp = expectation(description: "")

        httpServerBuilder
            .route(HttpRoute(endpoint: HttpEndpoint("/login"), response: httpResponse))
            .buildAndStart()

        let url = URL(string: "http://localhost:8080/login")!
        let session = URLSession(configuration: URLSessionConfiguration.default)
        session.dataTask(with: url, completionHandler: { (data, response, error) in
            XCTAssertNil(error)
            XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
            XCTAssertEqual(httpResponse.body, data!)
            exp.fulfill()
        }).resume()

        waitForExpectations(timeout: 5) { (error) in
            print("Error:\(String(describing: error))")
        }
    }

    func testWithTwoEndpoint() throws {
        let exp00 = expectation(description: "expectation 00")
        let exp01 = expectation(description: "expectation 01")

        httpServerBuilder
            .route(HttpRoute(endpoint: HttpEndpoint("/endpoint00"), response: HttpResponse(body: Data())))
            .route(HttpRoute(endpoint: HttpEndpoint("/endpoint01"), response: HttpResponse(body: Data())))
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
    
    
    func testResponseHeaders() throws {
        let httpResponse = HttpResponse(body: "xyz".data(using: .ascii)!, headers: ["key1": "value1"])
        let exp = expectation(description: "")

        httpServerBuilder
            .route(HttpRoute(endpoint: HttpEndpoint("/login"), response: httpResponse))
            .buildAndStart()

        let url = URL(string: "http://localhost:8080/login")!
        let session = URLSession(configuration: URLSessionConfiguration.default)
        session.dataTask(with: url, completionHandler: { (data, response, error) in
            XCTAssertNil(error)
            let headers: [String : String]? = (response as? HTTPURLResponse)?.allHeaderFields as? [String : String]
            XCTAssertNotNil(headers)
            XCTAssertEqual(headers!["key1"], "value1")
            XCTAssertEqual(httpResponse.body, data!)
            exp.fulfill()
        }).resume()

        waitForExpectations(timeout: 5) { (error) in
            print("Error:\(String(describing: error))")
        }
    }
}
