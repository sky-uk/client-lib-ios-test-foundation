import Foundation
import XCTest

public func tap(_ element: XCUIElement, _ message: String = "", file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertTrue(element.waitForExistence(timeout: expectationTimeout), "\(message) - \(element) does not exist.", file: file, line: line)
    element.tap()
}

public func swipeUp() {
    XCUIApplication().swipeUp()
}

public func swipeLeft() {
    XCUIApplication().swipeLeft()
}

public func swipeRight() {
    XCUIApplication().swipeRight()
}

public func swipeDown() {
    XCUIApplication().swipeDown()
}

public func swipeUp(_ element: XCUIElement, file: StaticString = #filePath, line: UInt = #line) {
    exist(element, file: file, line: line)
    element.swipeUp()
}

public func swipeDown(_ element: XCUIElement, file: StaticString = #filePath, line: UInt = #line) {
    exist(element, file: file, line: line)
    element.swipeDown()
}

public func swipeLeft(_ element: XCUIElement, file: StaticString = #filePath, line: UInt = #line) {
    exist(element, file: file, line: line)
    element.swipeLeft()
}

public func swipeRight(_ element: XCUIElement, file: StaticString = #filePath, line: UInt = #line) {
    exist(element, file: file, line: line)
    element.swipeRight()
}

public func typeText(_ element: XCUIElement,_ stringToBeTyped: String) {
    tap(element)
    element.typeText(stringToBeTyped)
}

public func typeText(_ stringToBeTyped: String) {
    XCUIApplication().typeText(stringToBeTyped)
}

