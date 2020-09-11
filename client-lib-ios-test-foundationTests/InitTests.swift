//
//  InitTests.swift
//  client-lib-ios-test-foundationTests
//
//  Created by Sky on 11/09/2020.
//  Copyright © 2020 Sky. All rights reserved.
//

import XCTest

@testable import client_lib_ios_test_foundation

class InitTests: XCTestCase {

    func testInit() {
        XCTAssertNotNil(HttpServerBuilder())
    }

    func testBuildAndStart() throws {
        let mockServer = try HttpServerBuilder().buildAndStart()
        XCTAssertNotNil(mockServer)
        mockServer.stop()

        try mockServer.start()
        mockServer.stop()
        XCTAssertNotNil(mockServer)
    }

}
