import Foundation
import SkyTestFoundation
import PetStoreSDK

public extension PetStoreSDK.Pet {
    static func mock(_id: Int = Int.mock(), category: PetStoreSDK.Category? = nil, name: String = String.mock(), status: PetStoreSDK.Pet.Status? = nil) -> PetStoreSDK.Pet {
        PetStoreSDK.Pet(_id: _id, category: category, name: name, status: status)
    }
}
public extension PetStoreSDK.Pet.Status {
    static func mock() -> PetStoreSDK.Pet.Status {
        PetStoreSDK.Pet.Status.allCases.randomElement()!
    }
}
