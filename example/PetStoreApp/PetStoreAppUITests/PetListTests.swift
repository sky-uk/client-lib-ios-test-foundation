import XCTest
import SkyTestFoundation
import PetStoreSDK
import PetStoreSDKTests

class PetList: SkyUITestCase {

    func testDisplayPetListView() {
        // Given
        let tom = Pet.mock(name: "Tom")
        let jerry = Pet.mock(name: "Jerry")

        httpServerBuilder
            .route(endpoint: Routes.User.login(),
                   on: Routes.User.loginHandler(username: "Ale", password: "Secret"))
            .route(MockResponses.Pet.findByStatus(pets: [jerry, tom]))
            .buildAndStart()

        // When
        appLaunch()

        // Then
        exist(withTextEquals("Please login"))
        typeText(withTextInput("Username"), "Ale")
        typeText(withSecureTextInput("Password"), "Secret")
        tap(withButton("Login"))

        exist(withTextEquals(tom.name))
        exist(withTextEquals(jerry.name))
    }

    func testTapDetailPetGivenGetNetworkNotFoundErrorThenShowErrorMessage() {
        // Given
        let tom = Pet.mock(name: "Tom")
        let jerry = Pet.mock(name: "Jerry")

        httpServerBuilder
            .route(endpoint: Routes.User.login(),
                   on: Routes.User.loginHandler(username: "Ale", password: "Secret"))
            .route(MockResponses.Pet.findByStatus(pets: [jerry, tom]))
            .buildAndStart()

        // When
        appLaunch()

        // Then
        exist(withTextEquals("Please login"))
        typeText(withTextInput("Username"), "Ale")
        typeText(withSecureTextInput("Password"), "Secret")
        tap(withButton("Login"))

        tap(withTextEquals(tom.name))
        exist(withTextEquals("Network Error"))
    }

    func testTapDetailThenValidUI() {
        // Given
        let tom = Pet.mock(name: "Tom")
        let jerry = Pet.mock(name: "Jerry")

        httpServerBuilder
            .route(endpoint: Routes.User.login(),
                   on: Routes.User.loginHandler(username: "Ale", password: "Secret"))
            .route(MockResponses.Pet.findByStatus(pets: [jerry, tom]))
            .route(MockResponses.Pet.getPetById(tom))
            .buildAndStart()

        // When
        appLaunch()

        // Then
        exist(withTextEquals("Please login"))
        typeText(withTextInput("Username"), "Ale")
        typeText(withSecureTextInput("Password"), "Secret")
        tap(withButton("Login"))

        tap(withTextEquals(tom.name))
    }

    func testTapDetailThenCheckHttpRequest() {
        // Given
        let tom = Pet.mock(name: "Tom")
        let jerry = Pet.mock(name: "Jerry")

        let pets = [jerry, tom]

        httpServerBuilder
            .route(endpoint: Routes.User.login(),
                   on: Routes.User.loginHandler(username: "Ale", password: "Secret"))
            .route(MockResponses.Pet.findByStatus(pets: pets), on: { request in
                assertEquals(request.queryParam("status"), "available")
            })
            .route(MockResponses.Pet.getPetById(tom))
            .buildAndStart()

        // When
        appLaunch()

        // Then
        exist(withTextEquals("Please login"))
        typeText(withTextInput("Username"), "Ale")
        typeText(withSecureTextInput("Password"), "Secret")
        tap(withButton("Login"))

        tap(withTextEquals(tom.name))
    }

    func testTapDetailWithDynamicMockReponse() {
        // Given
        let tom = Pet.mock(name: "Tom")
        let jerry = Pet.mock(name: "Jerry")

        let pets = [jerry, tom]

        httpServerBuilder
            .route(endpoint: Routes.User.login(), on: Routes.User.loginHandler(username: "Ale", password: "Secret"))
            .route(endpoint: MockResponses.Pet.findByStatus(pets: pets).endpoint) { request in
                assertEquals(request.queryParam("status"), "available")
                return HttpResponse(body: pets.encoded())
            }
            .route(MockResponses.Pet.getPetById(tom))
            .buildAndStart()

        // When
        appLaunch()

        // Then
        exist(withTextEquals("Please login"))
        typeText(withTextInput("Username"), "Ale")
        typeText(withSecureTextInput("Password"), "Secret")
        tap(withButton("Login"))

        tap(withTextEquals(tom.name))
    }

}
