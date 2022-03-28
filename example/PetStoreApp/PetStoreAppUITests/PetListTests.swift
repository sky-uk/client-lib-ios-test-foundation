import XCTest
import SkyTestFoundation
import PetStoreSDK
import PetStoreSDKTests

class PetList: UITests {

    func testDisplayPetListView() {
        // Given
        let tom = Pet.mock(name: "Tom")
        let jerry = Pet.mock(name: "Jerry")

        let pets = [jerry, tom]
        httpServerBuilder
            .handleLogin()
            .route(MockResponses.Pet.findByStatus(pets: pets))
            .buildAndStart()

        // When
        appLaunch()
        LoginTests.performLogin()

        // Then
        exist(withTextEquals(tom.name))
        exist(withTextEquals(jerry.name))
    }

    func testTapDetailPetGivenGetNetworkNotFoundErrorThenShowErrorMessage() {
        // Given
        let tom = Pet.mock(name: "Tom")
        let jerry = Pet.mock(name: "Jerry")

        let pets = [jerry, tom]
        httpServerBuilder
            .handleLogin()
            .route(MockResponses.Pet.findByStatus(pets: pets))
            .buildAndStart()

        // When
        appLaunch()
        LoginTests.performLogin()

        // Then
        tap(withTextEquals(tom.name))
        exist(withTextEquals("Network Error"))
    }

    func testTapDetailThenValidUI() {
        // Given
        let tom = Pet.mock(name: "Tom")
        let jerry = Pet.mock(name: "Jerry")

        let pets = [jerry, tom]
        httpServerBuilder
            .handleLogin()
            .route(MockResponses.Pet.findByStatus(pets: pets))
            .route(MockResponses.Pet.getPetById(tom))
            .buildAndStart()

        // When
        appLaunch()
        LoginTests.performLogin()

        // Then
        tap(withTextEquals(tom.name))
    }

    func testTapDetailThenCheckHttpRequest() {
        // Given
        let tom = Pet.mock(name: "Tom")
        let jerry = Pet.mock(name: "Jerry")

        let pets = [jerry, tom]
        httpServerBuilder
            .handleLogin()
            .route(MockResponses.Pet.findByStatus(pets: pets), on: { request in
                assertEquals(request.queryParam("status"), "available")
            })
            .route(MockResponses.Pet.getPetById(tom))
            .buildAndStart()

        // When
        appLaunch()
        LoginTests.performLogin()

        // Then
        tap(withTextEquals(tom.name))
    }

    func testTapDetailWithDynamicMockReponse() {
        // Given
        let tom = Pet.mock(name: "Tom")
        let jerry = Pet.mock(name: "Jerry")

        let pets = [jerry, tom]
        httpServerBuilder
            .handleLogin()
            .route(endpoint: MockResponses.Pet.findByStatus(pets: pets).endpoint) { request in
                assertEquals(request.queryParam("status"), "available")
                return HttpResponse(body: pets.encoded())
            }
            .route(MockResponses.Pet.getPetById(tom))
            .buildAndStart()

        // When
        appLaunch()
        LoginTests.performLogin()

        // Then
        tap(withTextEquals(tom.name))
    }

}
