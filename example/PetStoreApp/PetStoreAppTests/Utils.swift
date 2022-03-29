import Foundation

extension Encodable {
    func encoded() -> Data {
        try! JSONEncoder().encode(self)
    }
}
