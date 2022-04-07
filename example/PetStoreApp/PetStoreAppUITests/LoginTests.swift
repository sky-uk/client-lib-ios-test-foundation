import XCTest
import SkyTestFoundation

class LoginTests: SkyUITestCase {

    func testLogin() {
        // Given
        httpServerBuilder
            .route(endpoint: Routes.User.login(),
                   on: Routes.User.loginHandler(username: "Ale", password: "Secret"))
            .buildAndStart()

        // When
        appLaunch()

        // Then
        exist(withTextEquals("Please login"))
        typeText(withTextInput("Username"), "Ale")
        typeText(withSecureTextInput("Password"), "Secret")
        tap(withButton("Login"))

        notExist(withTextEquals("Please login"))
    }

    func testLoginGivenUnauthorized() {
        // Given
        httpServerBuilder
            .route(endpoint: Routes.User.login(),
                   on: Routes.User.loginHandler(username: "Ale", password: "Secret"))
            .buildAndStart()

        // When
        appLaunch()

        // Then
        exist(withTextEquals("Please login"))
        typeText(withTextInput("Username"), "Wrong")
        typeText(withSecureTextInput("Password"), "Credentials")
        tap(withButton("Login"))

        exist(withTextEquals("Invalid Credentials"))
        tap(withButton("OK"))
        exist(withTextEquals("Please login"))
    }

}
