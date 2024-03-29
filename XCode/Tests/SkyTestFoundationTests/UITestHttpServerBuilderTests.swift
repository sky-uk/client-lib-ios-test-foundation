import XCTest
@testable import SkyTestFoundation

class UITestHttpServerBuilderTest: XCTestCase {

    func testInit() {
        XCTAssertNotNil(UITestHttpServerBuilder())
    }

    func testBuildAndStart() throws {
        let mockServer = UITestHttpServerBuilder().buildAndStart()
        XCTAssertNotNil(mockServer)
        mockServer.stop()

        try mockServer.start()
        mockServer.stop()
        XCTAssertNotNil(mockServer)
    }
}
