import XCTest
import PetStoreSDK
import PetStoreSDKTests
import SkyTestFoundation

class FoodTests: SkyUITestCase {
    /* FOOD ADDITIONS START
    func testFoodDetail() {
        // Given
        let tom = Pet.mock(name: "Tom")
        let jerry = Pet.mock(name: "Jerry")
        
        let food = Food.mock(name: "Pizza")
        
        httpServerBuilder.routeImagesAt(path: "/v2/food/:path/image", properties: nil)
        
        httpServerBuilder
            .route(endpoint: Routes.User.login(), on: Routes.User.loginHandler(username: "Ale", password: "Secret"))
            .route(MockResponses.Pet.findByStatus(pets: [jerry, tom]))
            .route(MockResponses.Pet.getPetById(tom))
            .route(MockResponses.Food.foodSuggestions(foods: [food]))
            .buildAndStart()

        // When
        appLaunch()

        // Then
        exist(withTextEquals("Please login"))
        typeText(withTextInput("Username"), "Ale")
        typeText(withSecureTextInput("Password"), "Secret")
        tap(withButton("Login"))

        tap(withTextEquals(tom.name))
        
        tap(withButton("Suggest food"))
        exist(withTextEquals(food.price.formatted()))
        exist(withTextEquals(food.name))
    }
    FOOD ADDITIONS END */
}
