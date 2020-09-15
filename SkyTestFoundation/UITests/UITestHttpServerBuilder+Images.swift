import Foundation
import Swifter

extension UITestHttpServerBuilder.EndpointReport {
    func edited(receivedCallCount: Int) -> UITestHttpServerBuilder.EndpointReport {
        UITestHttpServerBuilder.EndpointReport(
            endpoint: endpoint,
            responseCount: responseCount,
            httpRequestCount: receivedCallCount
        )
    }

    func string() -> String {
        return "endpoint: \(endpoint) expected call count:\(responseCount) received call count: \(httpRequestCount)"
    }
}

extension Sequence where Element == UITestHttpServerBuilder.EndpointReport {
    func filter(_ endpoint: String) -> Element? {
        return self.first { $0.endpoint == endpoint }
    }

    func string() -> String {
        return self.reduce("") { (result, report) -> String in
            return report.string() + result
        }
    }
}

extension HttpServer {
    var port: Int {
        return (try? self.port()) ?? 8080
    }
}

extension Swifter.HttpRequest {

    func queryParam(key: String) -> String? {
        return queryParams.first { $0.0 == key }?.1
    }

    func pathParam(key: String = ":path") -> String? {
        params.first { $0.0 == key }?.1
    }
}

public func encode<T: Encodable>(value: T) throws -> Data {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .custom({ (date, encoder) in
        var container = encoder.singleValueContainer()
        let encodedDate = ISO8601DateFormatter().string(from: date)
        try container.encode(encodedDate)
    })
    return try encoder.encode(value)
}
