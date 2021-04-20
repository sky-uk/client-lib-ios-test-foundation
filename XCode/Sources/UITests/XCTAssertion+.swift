import XCTest
import Foundation

let expectationTimeout: Double = 30
let notExpectationTimeout: Double = 1

@discardableResult
public func exist(_ element: XCUIElement, _ message: String = "", file: StaticString = #filePath, line: UInt = #line) -> XCUIElement {
    XCTAssertTrue(element.waitForExistence(timeout: expectationTimeout), "\(message) - \(element) does not exist.", file: file, line: line)
    return element
}

public func notExist(_ element: XCUIElement, _ message: String = "", file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertFalse(element.waitForExistence(timeout: notExpectationTimeout), "\(message) - \(element) does exist.", file: file, line: line)
}

public func tap(_ element: XCUIElement, _ message: String = "", file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertTrue(element.waitForExistence(timeout: expectationTimeout), "\(message) - \(element) does not exist.", file: file, line: line)
    element.tap()
}

@discardableResult
public func isEnabled(_ element: XCUIElement, _ message: String = "", file: StaticString = #filePath, line: UInt = #line) -> XCUIElement {
    XCTAssertEqual(element.elementType, .button, "\(message) - \(element) is not of type Button.", file: file, line: line)
    XCTAssertTrue(element.waitForExistence(timeout: expectationTimeout), "\(message) - \(element) does not exist.", file: file, line: line)
    XCTAssertTrue(element.isEnabled)
    return element
}

@discardableResult
public func isDisabled(_ element: XCUIElement, _ message: String = "", file: StaticString = #filePath, line: UInt = #line) -> XCUIElement {
    XCTAssertEqual(element.elementType, .button, "\(message) - \(element) is not of type Button.", file: file, line: line)
    XCTAssertTrue(element.waitForExistence(timeout: expectationTimeout), "\(message) - \(element) does not exist.", file: file, line: line)
    XCTAssertFalse(element.isEnabled, file: file, line: line)
    return element
}

public func isRunningOnSimulator() -> Bool {
    return ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] != nil
}

public func withText(_ value: String) -> XCUIElement {
    let predicate = NSPredicate(format: "label ==[c] %@", value)
    return XCUIApplication().staticTexts.containing(predicate).firstMatch
}

public extension XCUIElement {
    func withText(_ value: String) -> XCUIElement {
        let predicate = NSPredicate(format: "label ==[c] %@", value)
        return staticTexts.containing(predicate).firstMatch
    }

    func withText(_ value: String) -> XCUIElementQuery {
        let predicate = NSPredicate(format: "label ==[c] %@", value)
        return staticTexts.containing(predicate)
    }

    func withTextContaining(_ value: String) -> XCUIElement {
        let predicate = NSPredicate(format: "label CONTAINS[c] %@", value)
        return staticTexts.containing(predicate).firstMatch
    }
}

public func withIndex(_ query: XCUIElementQuery, index: Int) -> XCUIElement {
    return query.element(boundBy: index)
}

public extension String {
    func takeLast(_ maxLength: Int) -> String {
        return String(suffix(maxLength))
    }

    func takeFirst(_ maxLength: Int) -> String {
        return String(prefix(maxLength))
    }

    func toUpperCase() -> String {
        return self.uppercased()
    }
}
