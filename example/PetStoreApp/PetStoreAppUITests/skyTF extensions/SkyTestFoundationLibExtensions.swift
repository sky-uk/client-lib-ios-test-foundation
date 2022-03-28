import Foundation
import SkyTestFoundation
import XCTest

// TODO: Add in sky test foundation

extension HttpEndpoint {
    func with(_ value: Encodable, _ statusCode: Int = 200) -> HttpRoute {
        HttpRoute(endpoint: self, response: HttpResponse(body: value.encoded(), statusCode: statusCode))
    }
}

extension Encodable {
    func encoded() -> Data {
        try! JSONEncoder().encode(self)
    }
}

extension String {
    var otherElement: XCUIElement {
        XCUIApplication().otherElements[self].firstMatch
    }

    var buttonElement: XCUIElement {
        XCUIApplication().buttons[self].firstMatch
    }

    var navBarButtonElement: XCUIElement {
        XCUIApplication().navigationBars.buttons[self].firstMatch
    }

    var tabBarButtonElement: XCUIElement {
        XCUIApplication().tabBars.buttons[self].firstMatch
    }

    var staticTextElement: XCUIElement {
        XCUIApplication().staticTexts[self].firstMatch
    }

    var textField: XCUIElement {
        XCUIApplication().textFields[self].firstMatch
    }

    var textView: XCUIElement {
        XCUIApplication().textViews[self].firstMatch
    }
}

func withButton(_ label: String) -> XCUIElement {
    XCUIApplication().buttons[label].firstMatch
}

func withTextInput(_ hint: String) -> XCUIElement {
    XCUIApplication().textFields[hint]
}

func withSecureTextInput(_ hint: String) -> XCUIElement {
    XCUIApplication().secureTextFields[hint]
}
