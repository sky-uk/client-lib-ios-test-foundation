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

@discardableResult
public func isEnabled(_ element: XCUIElement, _ message: String = "", file: StaticString = #filePath, line: UInt = #line) -> XCUIElement {
    XCTAssertEqual(element.elementType, .button, "\(message) - \(element) is not of type Button.", file: file, line: line)
    XCTAssertTrue(element.waitForExistence(timeout: expectationTimeout), "\(message) - \(element) does not exist.", file: file, line: line)
    XCTAssertTrue(element.isEnabled,"\(element) is not enabled.", file: file, line: line)
    return element
}

@discardableResult
public func isDisabled(_ element: XCUIElement, _ message: String = "", file: StaticString = #filePath, line: UInt = #line) -> XCUIElement {
    XCTAssertEqual(element.elementType, .button, "\(message) - \(element) is not of type Button.", file: file, line: line)
    XCTAssertTrue(element.waitForExistence(timeout: expectationTimeout), "\(message) - \(element) does not exist.", file: file, line: line)
    XCTAssertFalse(element.isEnabled, "\(element) is not disabled.", file: file, line: line)
    return element
}

public func isRunningOnSimulator() -> Bool {
    return ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] != nil
}

public func withTextEquals(_ value: String) -> XCUIElement {
    let predicate = NSPredicate(format: "label ==[c] %@", value)
    let result: XCUIElementQuery = XCUIApplication().staticTexts.containing(predicate)
    return result.firstMatch
}

public func withIndex(_ query: XCUIElementQuery, index: Int) -> XCUIElement {
    return query.element(boundBy: index)
}

public func assertViewCount(_ element: XCUIElementQuery, _ expectedCount: Int) {
    XCTAssertEqual(element.count, expectedCount, "assertViewCount failed: view count is not equals to expectedCount \(expectedCount)")
}

public func withTextContains(_ value: String) -> XCUIElement {
    let predicate = NSPredicate(format: "label CONTAINS[c] %@", value)
    let result: XCUIElementQuery = XCUIApplication().staticTexts.containing(predicate)
    return result.containing(predicate).firstMatch
}

public extension XCUIElement {
    func withTextEquals(_ value: String) -> XCUIElement {
        let predicate = NSPredicate(format: "label ==[c] %@", value)
        return staticTexts.containing(predicate).firstMatch
    }

    func withTextEquals(_ value: String) -> XCUIElementQuery {
        let predicate = NSPredicate(format: "label ==[c] %@", value)
        return staticTexts.containing(predicate)
    }

    func withTextContains(_ value: String) -> XCUIElement {
        let predicate = NSPredicate(format: "label CONTAINS[c] %@", value)
        return staticTexts.containing(predicate).firstMatch
    }
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

public extension XCUIElement {
    func withTextInput(_ hint: String) -> XCUIElement {
        return textFields[hint]
    }
}

#if !os(tvOS)
// MARK: Gestures
public func tap(_ element: XCUIElement, _ message: String = "", file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertTrue(element.waitForExistence(timeout: expectationTimeout), "\(message) - \(element) does not exist.", file: file, line: line)
    element.tap()
}

public func doubleTap(_ element: XCUIElement, _ message: String = "", file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertTrue(element.waitForExistence(timeout: expectationTimeout), "\(message) - \(element) does not exist.", file: file, line: line)
    element.doubleTap()
}
#endif

#if canImport(UIKit)
#if !os(tvOS)
public func swipeUp(velocity: XCUIGestureVelocity = .default) {
    waitForAWhile(0.5)
    XCUIApplication().swipeUp(velocity: velocity)
    waitForAWhile(0.5)
}

public func swipeLeft(velocity: XCUIGestureVelocity = .default) {
    waitForAWhile(0.5)
    XCUIApplication().swipeLeft(velocity: velocity)
    waitForAWhile(0.5)
}

public func swipeRight(velocity: XCUIGestureVelocity = .default) {
    waitForAWhile(0.5)
    XCUIApplication().swipeRight(velocity: velocity)
    waitForAWhile(0.5)
}

public func swipeDown(velocity: XCUIGestureVelocity = .default) {
    waitForAWhile(0.5)
    XCUIApplication().swipeDown(velocity: velocity)
    waitForAWhile(0.5)
}

public func swipeUp(_ element: XCUIElement, velocity: XCUIGestureVelocity = .default, file: StaticString = #filePath, line: UInt = #line) {
    exist(element, file: file, line: line)
    element.swipeUp(velocity: velocity)
    waitForAWhile(0.5)
}

public func swipeDown(_ element: XCUIElement, velocity: XCUIGestureVelocity = .default, file: StaticString = #filePath, line: UInt = #line) {
    exist(element, file: file, line: line)
    element.swipeDown(velocity: velocity)
    waitForAWhile(0.5)
}

public func swipeLeft(_ element: XCUIElement, velocity: XCUIGestureVelocity = .default, file: StaticString = #filePath, line: UInt = #line) {
    exist(element, file: file, line: line)
    element.swipeLeft(velocity: velocity)
    waitForAWhile(0.5)
}

public func swipeRight(_ element: XCUIElement, velocity: XCUIGestureVelocity = .default, file: StaticString = #filePath, line: UInt = #line) {
    exist(element, file: file, line: line)
    element.swipeRight(velocity: velocity)
    waitForAWhile(0.5)
}
#endif // os(tvOS)
public func typeText(_ stringToBeTyped: String) {
    XCUIApplication().typeText(stringToBeTyped)
}

public func waitForAWhile(_ seconds: Double = 2) {
    _ = XCUIApplication().staticTexts["_not_exist_element_"].waitForExistence(timeout: seconds)
}

#endif

#if !os(tvOS)
public func typeText(_ element: XCUIElement, _ stringToBeTyped: String) {
    tap(element)
    element.typeText(stringToBeTyped)
}
#endif

public func skipRunTestIf(_ condition: Bool, _ message: String, file: StaticString = #filePath, line: UInt = #line) throws {
    try XCTSkipIf(condition, message, file: file, line: line)
}

@discardableResult
public func isSelected(_ element: XCUIElement, _ message: String = "", file: StaticString = #filePath, line: UInt = #line) -> XCUIElement {
  let element = exist(element, message, file: file, line: line)
  XCTAssertTrue(element.isSelected, message, file: file, line: line)
  return element
}
@discardableResult
public func isNotSelected(_ element: XCUIElement, _ message: String = "", file: StaticString = #filePath, line: UInt = #line) -> XCUIElement {
  let element = exist(element, message, file: file, line: line)
  XCTAssertFalse(element.isSelected, message, file: file, line: line)
  return element
}


public extension Array where Element: Equatable {
    func randomExcept(_ items: [Element]) -> Element? {
        return compactMap({ (item) -> Element? in
            return !items.contains(item) ? item : nil
        }).randomElement()
    }
}
