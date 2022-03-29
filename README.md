# Sky Test Foundation (SkyTF) iOS [![CircleCI](https://circleci.com/gh/sky-uk/client-lib-ios-test-foundation/tree/master.svg?style=svg&circle-token=6a18106ecc99952ea6841f658f86282b5ff557f5)](https://circleci.com/gh/sky-uk/client-lib-ios-test-foundation/tree/master)
Sky Test Foundation defines a domain specific language to facilitate developers writing automatic tests.

It's meant to be mobile app tests' `lingua franca`. Out of the box, it allows you to port tests between iOS and Android by simply copy-pasting Swift to Kotlin or vice-versa. Sky Test Foundation for Android is still in progress.
![sky_test_foundation_layers](https://user-images.githubusercontent.com/51656240/160561639-d79e813f-9083-41bd-9869-4849a7a1bfb4.png)
The DSL allows you to define:
- http responses received by the app
- a sequence of user gestures

during test execution.

## Terminology
* UX = User Experience
* SUT = System Under Test
* MA = Mobile App
* BE = Backend

## Adopted Test Technique
Sky Test Foundation adopts BlackBox test technique. In general, BlackBox test technique does not require specific knowledge of the application's code, internal structure and/or programming knowledge. MA is seen as a black box as illustrated below:

![blackbox](https://user-images.githubusercontent.com/51656240/160555800-6a6be6b0-86a2-4f86-b08b-3546cf1f71a8.png)
MA output depends on:
- user activity (user gestures)
- BE state (BE http responses) 
- MA storage (Persistence Storage)

Outputs are:
- UI elements displayed to the user
- HTTP requests executed by the app

Tests verify the correctness of MA's behaviour defining asserts on Black Box's inputs and/or outputs.

During test execution, SkyTF allows you to:
- mock HTTP responses received by the App. You can also make assertions on each HTTP request sent by the app
- assert UI elements existence in view hierarchy
- simulate user gestures

## Usage
Extend `SkyUITestCase` for UI tests and `SkyUnitTestCase` for Unit test cases.

### SkyUnitTestCase - Unit Test example with SUT performing Http Requests
The goal of this kind of unit tests is to verify the correctness of the http requests performed by the MA. Using `httpServerBuilder` you can define the exact mock server's state during test execution, as a set of http routes.

Note: `.replaceHostnameWithLocalhost()` in `setUp()` is needed to forward http request performed by MA to the local mock server running on localhost.

```swift
import XCTest
import SkyTestFoundation
import RxBlocking
import PetStoreSDK
import PetStoreSDKTests
@testable import PetStoreApp

class LoginAPITests: SkyUnitTestCase {

    var sut: Services?

    override func setUp() {
        super.setUp()
        sut = Services(baseUrl: Urls.baseUrl().replaceHostnameWithLocalhost())
    }

    func testLogin() async throws {
        // Given
        var loginCallCount = 0
        let apiResponse = ApiResponse.mock(code: 200)
        
        httpServerBuilder.route(Routes.User.login().path) { request, callCount in
            loginCallCount = callCount
            assertEquals(request.queryParam("username"), "Alessandro")
            assertEquals(request.queryParam("password"), "Secret")
            return HttpResponse(body: apiResponse.encoded())
        }.onUnexpected{ httpRequest in
            assertFail("Unexpected http request: \(httpRequest)")
        }
        .buildAndStart()
        
        // When
        let pets = try await sut!.user.loginUser(username: "Alessandro", password: "Secret").value
    
        // Then
        assertNotNull(pets)
        assertEquals(loginCallCount, 1)
    }
}

```
Basic test structure:
 - `Given`. Here you define your initial state on HTTP server mocks. In this case we defined a login route.
 - `When`. Here you call all the methods to be tested. In this case we called the `loginUser` method.
 - `Then`. Here you write all the assertions. In this case we checked `pets` is not `nil` and made sure we called login only once.

If the method under test performs an http request not handled by the mock server, then `onUnexpected`'s closure `(HttpRequest) -> ()` is called.

Note: 
- `Routes.User.login().path` is a relative path not containing `127.0.0.1:8080`

See the mobile app located in folder `example` for more details.

### SkyUITestCase - PetStore App Example
Suppose we have the following user story:
```
As User
I want to login 
So that 
I can see a list of available pets
```
![login_petlist2](https://user-images.githubusercontent.com/51656240/160643374-c73dbd0a-16e7-4ed5-9d87-fbd32a0e3b28.jpg)

More details of the user story are illustrated in the following picture
![sequence_](https://user-images.githubusercontent.com/51656240/160642377-d8a69ab6-861b-45c9-8b51-e7e66bb38e1d.jpg)

And finally let's try write a test with the help of SkyTF's DSL.
 
```swift
class PetList: SkyUITestCase {

    func testDisplayPetListView() {

          // Given
          let tom = Pet.mock(name: "Tom")
          let jerry = Pet.mock(name: "Jerry")
          let pets = [jerry, tom]

          httpServerBuilder
              .route(MockResponses.User.successLogin())
              .route(MockResponses.Pet.findByStatus(pets: pets))
              .buildAndStart()

          // When
          appLaunch()

          typeText(withTextInput("Username"), "Alessandro")
          typeText(withTextInput("Password"), "Secret")
          tap(withButton(“Login"))

          // Then
          exist(withTextEquals(tom.name))
          exist(withTextEquals(jerry.name))
    }
}
 ``` 
In the "Given" section we defined http mock responses required by the app, in the "When" section the app is launched and the "Login" button is tapped after user credentials are typed.
Finally in the "Then" section we assert the existence in the view hierarchy of two pets returned by the mock server.

### Mock Server Builders
SkyUITestCase and SkyUnitTestCase provide mock server builder to easy the definition of the mock server routes. Builder can be accessed using the variable `httpServerBuilder` defined in SkyUITestCase and SkyUnitTestCase.

#### API - UI mock server builder
Available methods of `httpServerBuilder`:
```swift
func route(_ response: (endpoint: String, statusCode: Int, body: Data, responseTime: UInt32?), on: ((Swifter.HttpRequest) -> Void)? = nil) -> UITestHttpServerBuilder
```
Adds http route to mock server. Clousure `on` is called on main the thread when a http request with path equals to `endpoint` is received by the mock server.

```swift
func route(endpoint: String, on: @escaping ((Swifter.HttpRequest) -> HttpResponse)) -> UITestHttpServerBuilder
```
Adds http route to mock server. Closure `on` is called on a background thread when a http request with path equals to `endpoint` is received by the mock server. The closure allows to define different Http responses given the same endpoint.

```swift
func buildAndStart(port: in_port_t = 8080, file: StaticString = #file, line: UInt = #line) throws -> HttpServer
```
Build all routes added so far and starts the mock server. 

Example
```swift
import XCTest
import Swifter
import SkyTestFoundation
class UITests: SkyUITestCase {
    func test() throws {
        // Given
        httpServerBuilder
            .route(endpoint: "/endpoint1", on: { (request) -> HttpResponse in
                return HttpResponse.raw(statusCode: 200, body: Data())
            })
            .buildAndStart()

        appLaunched()
        // ...
    }
}
```
 
The test is composed by 3 sections:
- Given: mocks, http routes are defined and app is launced 
- When: ui gesture are performed in order to navigate to the view to be tested 
- Then: assertions on ui element of the view (to be tested)

## DSL for UI Testing
SkyTestFoundation provides a simple DSL in order to facilitate the writing of UI tests. It is a thin layer defined on top of primtives offered by XCTest. 
The same DSL for testing is defined for Android platform on top of Espresso (see [client-lib-android-test-foundation](https://github.com/sky-uk/client-lib-android-test-foundation)).
SkyTestFoundation custom assertions are wrappers of events defined in `XCUIElement` like `tap()`. DSL assertions wait for any element to appear before firing the wrapped event. One of the effect of using custom assertions is to reduce flakiness of ui test execution.

* **exist(_ element)** Determines if the element exists.
* **notExist(_ element)** Determines if the element NOT exists.
* **tap(_ element)** Sends a tap event to a hittable point computed for the element.
* **doubleTap(_ element)** Sends a double tap event to a hittable point computed for the element.
* **isEnabled(_ element)** Determines if the element is enabled for user interaction.
* **isNotEnabled(_ element)** Determines if the element is NOT enabled for user interaction.
* **isRunningOnSimulator()** -> Bool Returns true if ui test is running on iOS simulator. It can be used in conjunction with `XCTSkipIf/1` in order to skip the execution of a ui test if on iOS simulator.
* **withTextEquals(_ text)** A XCUIElementQuery query for locating staticText view elements equals to `text`
* **withTextContains(_ text)** A XCUIElementQuery query for locating staticText view elements containing `text`
* **withIndex(_ query, index)** the index-th element of the result of the query *query*
* **assertViewCount(_ query, expectedCount)** Asserts if the number of view matched by *query* is equals to *expectedCount*
* **swipeUp(_ element)** performs swipe up user gesture on element 
* **swipeDown(_ element)** performs swipe up user gesture on element
* **swipeLeft(_ element)** performs swipe up user gesture on element
* **swipeRight(_ element)** performs swipe up user gesture on element
* **swipeUp()** performs swipe up user gesture  
* **swipeDown()** performs swipe down user gesture 
* **swipeLeft()** performs swipe left user gesture 
* **swipeRight()** performs swipe right user gesture 

Notice: DSL for testing allows to write iOS UI Test and copy it to android and viceversa.
### Mocks - Random data generators
The framework provides mocks for built-in data types of Swift. In mock testing, the dependencies are replaced with objects that simulate the behavior of the real ones. The purpose of mocking is to isolate and focus on the code being tested and not on the behavior or state of external dependencies.
Each mocks returns a random value of the associated data type.


Example
```swift 
var v = String.mock()
print(v)  // prints 673D6E7C-ECE4-493C-B86B-25DAE78C02CC
v = String.mock()
print(v)  // prints 2D092A17-5BBB-4F91-8E4B-BC45A902D235
```
#### Real Data / Dictionaries
Real data dictionaries can be used to assign meaningful values to generated mocks. 
Available real data dictionaries are:
<img width="570" alt="realdatadic" src="https://user-images.githubusercontent.com/51656240/114414177-e3006200-9bae-11eb-9a78-714e4b6762ad.png">

Example
```swift 
var v = String.mock(.firstname) // randomly generate a firstname value
print(v) // prints Augusto
v = String.mock(.firstname)
print(v) // prints Elisa
```



## Installation
### Swift Package Manager
SPM is supported

### Demos
Source code available at: https://github.com/sky-uk/client-lib-ios-test-foundation/tree/demos
## Demo iOS App 
The app requests a text and an image to the mock sever. The project includes an UI test example showing mock server usage.

```swift
import XCTest
import SkyTestFoundation

class DemoIOSUITests: SkyUITestCase {

    func testMockServer() throws {
        // Given
        let text = "Hello world from SkyTestFoundation Mock Server."
        httpServerBuilder.routeImagesAt(path: "/image", properties: nil)
        try httpServerBuilder
            .route((endpoint: "/message", statusCode: 200, body: text.data(using: .utf8)!, responseTime: 0))
            .buildAndStart()
        // When
        let app = XCUIApplication()
        app.launch()
        // Then
        exist(app.staticTexts[text])
        exist(app.windows
                .children(matching: .other).element
                .children(matching: .other).element
                .children(matching: .other).element
                .children(matching: .image).element)

        httpServerBuilder.httpServer.stop()
    }
}
```
The following view will be displayed in the iOS simulator during the test execution:
![ demo_ios_app](https://user-images.githubusercontent.com/51656240/101651922-e4255500-3a3d-11eb-82bc-0bf8d067bcb7.png)

## Demo MacOS App 
The same test of Demo iOS App is executued. 

Note: pay attention to settings/capabilities of target app, in order to perform http request to localhost from the app, and entitlements set to UI test target in order to allow socket bind to localhost.

The following view is displayed during the execution of the test:

![demo_macos_app](https://user-images.githubusercontent.com/51656240/101652813-fce23a80-3a3e-11eb-9858-445d6734e5c1.jpg)

#### List of acronyms
- MA mobile iOS application
- SUT system under test

### Examples
#### Unit Test and callCount
`callCount` stores the number of http request call received by the mock server for a specific endpoint.
```swift
 func testCallCountExample() throws {
     let exp00 = expectation(description: "expectation 00")
     
     var callCount0 = 0
     var callCount1 = 0
     httpServerBuilder
       .route("/endpoint/1") { (request, callCount) -> (HttpResponse) in
           callCount0 = callCount
           return HttpResponse.ok(HttpResponseBody.data(Data()))
        }
        .route("/endpoint/2") { (request, callCount) -> (HttpResponse) in
            callCount1 = callCount
            return HttpResponse.ok(HttpResponseBody.data(Data()))
        }
        .buildAndStart()

        let session = URLSession(configuration: URLSessionConfiguration.default)

        let url00 = URL(string: "http://localhost:8080/endpoint/1")!
        let dataTask00 = session.dataTask(with: url00) { (_, _, error) in
            XCTAssertNil(error)
            exp00.fulfill()
        }

        dataTask00.resume()

    wait(for: [exp00], timeout: 3)
    XCTAssertEqual(callCount0, 1)
    XCTAssertEqual(callCount1, 0)
}
```
