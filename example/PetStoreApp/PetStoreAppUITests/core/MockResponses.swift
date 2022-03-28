import Foundation
import SkyTestFoundation
import PetStoreSDK
import PetStoreSDKTests

struct MockResponses {
    struct User {
        static func successLogin() -> HttpRoute {
            Routes.User.login().with(ApiResponse.mock(code: 200))
        }

        static func unauthorizedLogin() -> HttpRoute {
            Routes.User.login().with(ApiResponse.mock(code: 404))
        }
    }

    struct Pet {
        static func findByStatus(pets: [PetStoreSDK.Pet]) -> HttpRoute {
            Routes.Pet.findByStatus().with(pets)
        }

        static func getPetById(_ pet: PetStoreSDK.Pet) -> HttpRoute {
            Routes.Pet.getPeyById(petId: "\(pet._id)").with(pet)
        }
    }

    /* FOOD ADDITIONS START
    struct Food {
        static func foodSuggestions(foods: [PetStoreSDK.Food]) -> HttpRoute {
            return Routes.Food.foodSuggestions().with(foods)
        }
    }
    FOOD ADDITIONS END */
}
