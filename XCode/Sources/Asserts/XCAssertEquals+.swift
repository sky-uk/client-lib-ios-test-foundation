import Foundation
import XCTest

public enum URLComponent {
    case host
    case path
    case queryParameters
}

public func assertURLEquals(_ url1: String, _ url2: String, ignores: [URLComponent] = [], file: StaticString = #filePath, line: UInt = #line) {
    guard  let urlComponents1 = URLComponents(string: url1) else {
        XCTFail("Cannot get URL components of \(url1)")
        return
    }
    guard let urlComponents2 = URLComponents(string: url2) else {
        XCTFail("Cannot get URL components of \(url2)")
        return
    }

    if !ignores.contains(URLComponent.host) {
        XCTAssertEqual(urlComponents1.host, urlComponents2.host, "You can ignore url host comparision using 'ignores' parameter.", file: file, line: line)
    }

    if !ignores.contains(URLComponent.path) {
        XCTAssertEqual(urlComponents1.path, urlComponents2.path, "You can ignore path host comparision using 'ignores' parameter.", file: file, line: line)
    }

    let queryItems1 = urlComponents1.queryItems?.sorted(by: { (queryItem1, queryItem2) -> Bool in
        return queryItem1.name.lexicographicallyPrecedes(queryItem2.name)
    }) ?? []
    let queryItems2 = urlComponents2.queryItems?.sorted(by: { (queryItem1, queryItem2) -> Bool in
        return queryItem1.name.lexicographicallyPrecedes(queryItem2.name)
    }) ?? []

    if !ignores.contains(.queryParameters) {
        XCTAssertEqual(queryItems1.count, queryItems2.count, "Query parameters counts are not equal", file: file, line: line)
        if queryItems1.count == queryItems2.count {
            for index in 0..<queryItems1.count {
                let queryItem1 = queryItems1[index]
                let queryItem2 = queryItems2[index]
                XCTAssertEqual(queryItem1.name, queryItem2.name, "Query parameter name", file: file, line: line)
                XCTAssertEqual(queryItem1.value, queryItem2.value, "Query parameter value", file: file, line: line)
            }
        }
    }
}


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

public func assertTrue(_ expression: @autoclosure () throws -> Bool, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertTrue(try expression(), message(), file: file, line: line)
}

public func assertFalse(_ expression: @autoclosure () throws -> Bool, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertFalse(try expression(), message(), file: file, line: line)
}
