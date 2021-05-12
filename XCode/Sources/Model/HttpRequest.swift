import Foundation
import Swifter

public protocol HttpRequest {
    var path: String { get }
    var method: String { get }
    var body: [UInt8] { get }
    var address: String? { get }
    var headers: [String : String] { get }
    var params: [String: String] { get }
    var queryParams: [(String, String)] { get }
}

public extension HttpRequest {

    func header(name: String) -> String? {
        return self.headers[name]
    }

    func pathParam(key: String = ":path") -> String? {
        params.first { $0.0 == key }?.1
    }

    func queryParam(_ key: String) -> String? {
        let row = queryParams.first { $0.0.removingPercentEncoding == key }?.1
        return row?.removingPercentEncoding
    }
}
