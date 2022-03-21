import XCTest
@testable import SkyTestFoundation

class EndpointReportTests: XCTestCase {

    func testInit() {
        let endpoint = "xxxx"
        let responseCount = 1
        let httpRequestCount = 2
        let endpointReport = UITestHttpServerBuilder.EndpointReport(
            endpoint: HttpEndpoint(endpoint),
            responseCount: responseCount,
            httpRequestCount: httpRequestCount
        )
        XCTAssertEqual(endpointReport.endpoint.path, endpoint)
        XCTAssertEqual(endpointReport.endpoint.method, .get)
        XCTAssertEqual(endpointReport.responseCount, responseCount)
        XCTAssertEqual(endpointReport.httpRequestCount, httpRequestCount)
    }
}
