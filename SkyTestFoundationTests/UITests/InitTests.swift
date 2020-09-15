import XCTest
@testable import SkyTestFoundation

class InitTests: XCTestCase {

    func testInit() {
        XCTAssertNotNil(UITestHttpServerBuilder())
    }

    func testBuildAndStart() throws {
        let mockServer = try UITestHttpServerBuilder().buildAndStart()
        XCTAssertNotNil(mockServer)
        mockServer.stop()

        try mockServer.start()
        mockServer.stop()
        XCTAssertNotNil(mockServer)
    }
}
