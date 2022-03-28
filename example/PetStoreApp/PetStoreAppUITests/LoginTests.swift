import XCTest
import SkyTestFoundation

struct ValidCredentials {
    static let username = "Ale"
    static let password = "Secret"
}

extension UITestHttpServerBuilder {
    func handleLogin() -> UITestHttpServerBuilder {
        route(endpoint: Routes.User.login()) { request in
            guard
                request.queryParam("username") == ValidCredentials.username,
                request.queryParam("password") == ValidCredentials.password else {
                    return MockResponses.User.unauthorizedLogin().response
                }

            return MockResponses.User.successLogin().response
        }
    }
}

class LoginTests: UITests {

    static func performLogin(username: String = ValidCredentials.username,
                             password: String = ValidCredentials.password) {
        exist(withTextEquals("Please login"))
        typeText(withTextInput("Username"), username)
        typeText(withSecureTextInput("Password"), password)
        tap(withButton("Login"))
    }

    func testLogin() {
        // Given
        httpServerBuilder
            .handleLogin()
            .buildAndStart()

        // When
        appLaunch()

        // Then
        LoginTests.performLogin()
        notExist(withTextEquals("Please login"))
    }

    func testLoginGivenUnauthorized() {
        // Given
        httpServerBuilder
            .handleLogin()
            .buildAndStart()

        // When
        appLaunch()

        // Then
        LoginTests.performLogin(username: "Wrong", password: "Credentials")
        exist(withTextEquals("Invalid Credentials"))
        tap(withButton("OK"))
        exist(withTextEquals("Please login"))
    }

}
