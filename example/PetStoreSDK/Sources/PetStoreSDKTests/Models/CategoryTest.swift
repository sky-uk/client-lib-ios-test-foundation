import Foundation
import SkyTestFoundation
import PetStoreSDK
public extension PetStoreSDK.Category {
    static func mock(_id: Int? = nil, name: String? = nil) -> PetStoreSDK.Category {
        PetStoreSDK.Category(_id: _id, name: name)
    }
}
