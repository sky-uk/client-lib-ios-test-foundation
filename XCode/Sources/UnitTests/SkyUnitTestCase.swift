import XCTest

open class SkyUnitTestCase: XCTestCase {
    public var httpServerBuilder: UTHttpServerBuilder! = UTHttpServerBuilder()

    open override func setUp() {
        super.setUp()
        httpServerBuilder.httpServer.stop()
        httpServerBuilder = UTHttpServerBuilder()
    }

    open override func tearDown() {
        httpServerBuilder.httpServer.stop()
        super.tearDown()
    }
}

