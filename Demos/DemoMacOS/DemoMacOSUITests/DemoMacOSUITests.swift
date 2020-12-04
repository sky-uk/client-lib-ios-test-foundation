import XCTest
import SkyTestFoundation

class DemoMacOSUITests: SkyUITestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {

    }

    func testExample() throws {
        httpServerBuilder.routeImagesAt(path: "/image", properties: nil)
        let text = "Hello world."
        try httpServerBuilder.route((endpoint: "/message", statusCode: 200, body: text.data(using: .utf8)!, responseTime: 0))
            .buildAndStart()

        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        exist(app.windows.staticTexts[text])
    }
}
