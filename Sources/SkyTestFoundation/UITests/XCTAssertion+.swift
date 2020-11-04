import XCTest
import Foundation

let expectationTimeout: Double = 30
let expectationTimeout: Double = 1

@discardableResult
func exist(_ element: XCUIElement, _ message: String = "", file: StaticString = #filePath, line: UInt = #line) -> XCUIElement {
    XCTAssertTrue(element.waitForExistence(timeout: expectationTimeout), "\(message) - \(element) does not exist.", file: file, line: line)
    return element
}

func notExist(_ element: XCUIElement, _ message: String = "", file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertFalse(element.waitForExistence(timeout: notExpectationTimeout), "\(message) - \(element) does exist.", file: file, line: line)
}

func tap(_ element: XCUIElement, _ message: String = "", file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertTrue(element.waitForExistence(timeout: expectationTimeout), "\(message) - \(element) does not exist.", file: file, line: line)
    element.tap()
}

@discardableResult
func isEnabled(_ element: XCUIElement, _ message: String = "", file: StaticString = #filePath, line: UInt = #line) -> XCUIElement {
    XCTAssertEqual(element.elementType, .button, "\(message) - \(element) is not of type Button.", file: file, line: line)
    XCTAssertTrue(element.waitForExistence(timeout: expectationTimeout), "\(message) - \(element) does not exist.", file: file, line: line)
    XCTAssertTrue(element.isEnabled)
    return element
}

@discardableResult
func isDisabled(_ element: XCUIElement, _ message: String = "", file: StaticString = #filePath, line: UInt = #line) -> XCUIElement {
    XCTAssertEqual(element.elementType, .button, "\(message) - \(element) is not of type Button.", file: file, line: line)
    XCTAssertTrue(element.waitForExistence(timeout: expectationTimeout), "\(message) - \(element) does not exist.", file: file, line: line)
    XCTAssertFalse(element.isEnabled, file: file, line: line)
    return element
}

func isRunningOnSimulator() -> Bool {
    return ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] != nil
}
