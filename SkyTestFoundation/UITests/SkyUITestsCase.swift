import Foundation
import XCTest

open class SkyUITestCase: XCTestCase {
    public var httpServerBuilder: UITestHttpServerBuilder = UITestHttpServerBuilder()

    open override func setUp() {
        super.setUp()
        httpServerBuilder.httpServer.stop()
        httpServerBuilder = UITestHttpServerBuilder()
    }

    open override func tearDown() {
        httpServerBuilder.httpServer.stop()
        super.tearDown()
    }
}
