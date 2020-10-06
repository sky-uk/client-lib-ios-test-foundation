import Foundation
import Swifter

public extension HttpRequest {

    func header(name: String) -> String? {
        return self.headers[name]
    }

    func pathParam(key: String = ":path") -> String? {
        params.first { $0.0 == key }?.1
    }

    func queryParam(_ key: String) -> String? {
        let row = queryParams.first { $0.0 == key }?.1
        return row?.removingPercentEncoding
    }

}
