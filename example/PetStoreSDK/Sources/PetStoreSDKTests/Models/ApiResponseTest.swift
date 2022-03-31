import Foundation
import SkyTestFoundation
import PetStoreSDK

public extension PetStoreSDK.ApiResponse {
    static func mock(code: Int? = nil, type: String? = nil, message: String? = nil) -> PetStoreSDK.ApiResponse {
        PetStoreSDK.ApiResponse(code: code, type: type, message: message)
    }
}
