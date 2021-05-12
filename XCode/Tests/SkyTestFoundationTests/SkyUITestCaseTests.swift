import Foundation
import XCTest
@testable import SkyTestFoundation

class SkyUITestCaseTests: SkyUITestCase {
    
    func testSetup() {
        XCTAssertNotNil(httpServerBuilder)
        XCTAssertEqual(httpServerBuilder.httpServer.routes.count, 0)
    }
    
    func testOneEndpoint() throws {
        let body = "xyz".data(using: .ascii)!
        let exp = expectation(description: "")
        
        httpServerBuilder
            .route((route: HttpRoute("/login"), statusCode: 200, body: body, responseTime: nil))
            .buildAndStart()
        
        let url = URL(string: "http://localhost:8080/login")!
        let session = URLSession(configuration: URLSessionConfiguration.default)
        session.dataTask(with: url, completionHandler: { (data, response, error) in
            XCTAssertNil(error)
            XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
            XCTAssertEqual(body, data!)
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
            .route((route: HttpRoute("/endpoint00"), statusCode: 200, body: Data(), responseTime: nil))
            .route((route: HttpRoute("/endpoint01"), statusCode: 200, body: Data(), responseTime: nil))
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
}
