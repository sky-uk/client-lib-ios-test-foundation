import XCTest

@testable import SkyTestFoundation

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

