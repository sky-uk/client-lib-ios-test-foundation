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
