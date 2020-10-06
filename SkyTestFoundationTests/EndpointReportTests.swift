//
//  EndpointReportTests.swift
//  SkyTestFoundation-Tests
//
//  Created by Sky on 06/10/2020.
//

import XCTest
@testable import SkyTestFoundation

class EndpointReportTests: XCTestCase {

    func testInit() {
        let endpoint = "xxxx"
        let responseCount = 1
        let httpRequestCount = 2
        let endpointReport = UITestHttpServerBuilder.EndpointReport(
            endpoint: endpoint,
            responseCount: responseCount,
            httpRequestCount: httpRequestCount
        )
        XCTAssertEqual(endpointReport.endpoint, endpoint)
        XCTAssertEqual(endpointReport.responseCount, responseCount)
        XCTAssertEqual(endpointReport.httpRequestCount, httpRequestCount)
    }

}


