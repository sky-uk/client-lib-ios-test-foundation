import XCTest
import SkyTestFoundation

class DemoMacOSUITests: SkyUITestCase {

    func testMockServer() throws {
        // Given
        let text = "Hello world from SkyTestFoundation Mock Server."
        httpServerBuilder.routeImagesAt(path: "/image", properties: nil)
        try httpServerBuilder
            .route((endpoint: "/message", statusCode: 200, body: text.data(using: .utf8)!, responseTime: 0))
            .buildAndStart()
        // When
        let app = XCUIApplication()
        app.launch()
        // Then
        exist(app.windows.staticTexts[text])
        exist(app.windows.children(matching: .image).element)
        httpServerBuilder.httpServer.stop()
    }
}
