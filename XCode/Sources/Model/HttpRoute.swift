import Foundation

public struct HttpRoute: Hashable, CustomStringConvertible {
    let path: String
    let method: HttpMethod

    public init(_ path: String, _ method: HttpMethod = .get) {
        self.path = path
        self.method = method
    }

    public var description: String {
        return "\(method) \(path)"
    }
}
