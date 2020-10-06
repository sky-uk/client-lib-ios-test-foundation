import Foundation
import XCTest

class SkyUITestCase: XCTestCase {
    var httpServerBuilder: UITestHttpServerBuilder = UITestHttpServerBuilder()
    override func setUp() {
        super.setUp()
        httpServerBuilder.httpServer.stop()
        httpServerBuilder = UITestHttpServerBuilder()
    }

    override func tearDown() {
        httpServerBuilder.httpServer.stop()
        super.tearDown()
    }
}
