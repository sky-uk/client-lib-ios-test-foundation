import Foundation
import SkyTestFoundation
import PetStoreSDK
import PetStoreSDKTests

struct ValidCredentials {
    static let username = "Ale"
    static let password = "Secret"
}

struct Routes {
    struct User {
        static func login() -> HttpEndpoint { HttpEndpoint("/v2/user/login", HttpMethod.get) }

        static var loginHandler: (HttpRequest) -> HttpResponse = { request in
            guard
                request.queryParam("username") == ValidCredentials.username,
                request.queryParam("password") == ValidCredentials.password else {
                return MockResponses.User.unauthorizedLogin().response
            }

            return MockResponses.User.successLogin().response
        }

    }

    struct Pet {
        static func findByStatus() -> HttpEndpoint { HttpEndpoint("/v2/pet/findByStatus", HttpMethod.get) }

        static func getPeyById(petId: String = ":path") -> HttpEndpoint {  HttpEndpoint("/v2/pet/\(petId)", HttpMethod.get) }
    }

    /* FOOD ADDITIONS START
    struct Food {
        static func foodSuggestions(petId: String = ":path") -> HttpEndpoint { HttpEndpoint("/v2/food/:path/suggestions", HttpMethod.get) }
    }
    FOOD ADDITIONS END */
}
