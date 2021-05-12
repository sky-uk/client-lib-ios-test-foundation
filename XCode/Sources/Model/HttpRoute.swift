import Foundation

public struct HttpRoute: Hashable, CustomStringConvertible {
    public let path: String
    public let method: HttpMethod

    public init(_ path: String, _ method: HttpMethod = .get) {
        self.path = path
        self.method = method
    }

    public var description: String {
        return "\(method) \(path)"
    }
}
