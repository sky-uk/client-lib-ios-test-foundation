import XCTest
import SkyTestFoundation
import RxBlocking
import PetStoreSDK
import PetStoreSDKTests
@testable import PetStoreApp

class PetStoreAppTests: SkyUnitTestCase {

    var sut: Services?

    override func setUp() {
        super.setUp()
        sut = Services(baseUrl: Urls.baseUrl().replaceHostnameWithLocalhost())
    }

    func testLoginRequest() async throws {
        
        var loginCallCount = 0
        
        let apiResponse = ApiResponse.mock(code: 200)
        
        httpServerBuilder.route(Routes.User.login().path) { request, callCount in
            loginCallCount = callCount
            assertEquals(request.queryParam("username"), "Alessandro")
            assertEquals(request.queryParam("password"), "Secret")
            return HttpResponse(body: apiResponse.encoded())
        }
        .buildAndStart()
        
        let pets = try await sut!.user.loginUser(username: "Alessandro", password: "Secret").value
    
        assertNotNull(pets)
        assertEquals(loginCallCount, 1)
    }
}
