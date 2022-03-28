import Foundation
import SkyTestFoundation
import PetStoreSDK
public extension PetStoreSDK.Tag {
    static func mock(_id: Int? = nil, name: String? = nil) -> PetStoreSDK.Tag {
        PetStoreSDK.Tag(_id: _id, name: name)
    }
}
