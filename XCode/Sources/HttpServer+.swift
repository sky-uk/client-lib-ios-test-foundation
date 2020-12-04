import Foundation
import Swifter

public extension HttpServer {
    var port: Int {
        return (try? self.port()) ?? 8080
    }
}
