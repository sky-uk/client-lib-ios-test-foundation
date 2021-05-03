import Foundation
import XCTest

public func assertEquals<T>(_ expression1: @autoclosure () throws -> T,
                            _ expression2: @autoclosure () throws -> T,
                            _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) where T : Equatable {
    return XCTAssertEqual(try expression1(), try expression2(), message(), file: file, line: line)
}

public func assertEquals<T>(_ expression1: @autoclosure () throws -> T, _ expression2: @autoclosure () throws -> T, accuracy: T, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) where T : FloatingPoint {
    return XCTAssertEqual(try expression1(), try expression2(), accuracy: accuracy, message(), file: file, line: line)
}

public func assertEquals<T>(_ expression1: @autoclosure () throws -> T, _ expression2: @autoclosure () throws -> T, accuracy: T, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) where T : Numeric {
    return XCTAssertEqual(try expression1(), try expression2(), accuracy: accuracy, message(), file: file, line: line)
}

public func assertNotNull(_ expression: @autoclosure () throws -> Any?, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) {
    return XCTAssertNotNil(try expression(), message(), file: file, line: line)
}

public func assertNull(_ expression: @autoclosure () throws -> Any?, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) {
    return XCTAssertNil(try expression(), message(), file: file, line: line)
}
