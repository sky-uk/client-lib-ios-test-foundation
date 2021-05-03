import XCTest
import XCTest
@testable import SkyTestFoundation

class XCTAssertURLEqualTests: XCTestCase {

    func testHost() throws {
        assertURLEquals("http://www.sky.com", "http://www.sky.com")
        assertURLEquals("http://www.sky.XXX", "http://www.sky.com", ignores: [.host])
    }

    func testPath() {
        assertURLEquals("http://www.sky.com/path1", "http://www.sky.com/path1")
        assertURLEquals("http://www.sky.com/path1", "http://xxx.xxx.xxx/path1", ignores: [.host])
        assertURLEquals("http://www.sky.com/path1", "http://www.sky.com/path2", ignores: [.path])
    }

    func testQueryParameters() {
        assertURLEquals("http://www.sky.com?name1=value1", "http://www.sky.com?name1=value1")
        assertURLEquals("http://www.sky.com?name2=value2&name1=value1", "http://www.sky.com?name1=value1&name2=value2")
        assertURLEquals("http://www.sky.com", "http://www.sky.com?q1=value1", ignores: [.queryParameters])
    }
}
