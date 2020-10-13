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

public extension Sequence where Element == UITestHttpServerBuilder.EndpointReport {
    func filter(_ endpoint: String) -> Element? {
        return self.first { $0.endpoint == endpoint }
    }

    func string() -> String {
        return self.reduce("") { (result, report) -> String in
            return report.string() + result
        }
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
