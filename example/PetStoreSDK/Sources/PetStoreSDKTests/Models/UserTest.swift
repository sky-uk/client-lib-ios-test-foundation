import Foundation
import SkyTestFoundation
import PetStoreSDK
public extension PetStoreSDK.User {
    static func mock(_id: Int? = nil, username: String? = nil, firstName: String? = nil, lastName: String? = nil, email: String? = nil, password: String? = nil, phone: String? = nil, userStatus: Int? = nil) -> PetStoreSDK.User {
        PetStoreSDK.User(_id: _id, username: username, firstName: firstName, lastName: lastName, email: email, password: password, phone: phone, userStatus: userStatus)
    }
}
