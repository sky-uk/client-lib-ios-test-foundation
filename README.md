# Sky Test Foundation [![CircleCI](https://circleci.com/gh/sky-uk/client-lib-ios-test-foundation/tree/master.svg?style=svg&circle-token=6a18106ecc99952ea6841f658f86282b5ff557f5)](https://circleci.com/gh/sky-uk/client-lib-ios-test-foundation/tree/master)
Test suite for iOS mobile applications: a collection of tools and classes to facilitate the writing of automatic tests during development of an iOS mobile application.
The suite has to parts, one for Unit testing and the other one for User Interface (or functional) tests.
![sky_test_foundation_layers](https://user-images.githubusercontent.com/51656240/118296905-c2913380-b4dd-11eb-8cc7-6c1306aaf774.png)


## Test Environment
During tests execution, iOS Mobile App (MA) should interact with a Mock Server which appear to be the real counterparts of BE server. The framework provides a mock server that allows a tight control over what data the iOS App receives.
![](https://user-images.githubusercontent.com/51656240/94568277-9685b280-026c-11eb-80ac-d5a6d95bcdf3.png)
During the execution of the tests the MA must forward http requests to http://127.0.0.1:8080.

## SkyUITestCase/SkyUnitTestCase primary classes for defining test cases
SkyUITestCase and SkyUnitTestCase classes extend XCTestCase and define a mock server. Use SkyUITestCase and SkyUnitTestCase for UI and Unit test cases respectively.

### SkyUnitTestCase - Unit Test example with SUT performing Http Requests
The goal of this kind of unit test is to verify the correctness of the http requests performed by the MA. The `httpServerBuilder` object allows to define the state of the mock server as a set of http routes. Note `Urls.baseUrl().replaceHostnameWithLocalhost()` in the `setupUp()` forwards http request performed by MA to localhost.

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
In the `Given` section http mocks reponse are defined, in `When` section `loginUser/2` method of SUT (System Under Test) is called, finally in the `Then` section asserts on expected values are defined.
If the execution of the method under test performs an http request not handled by the mocks server then `onUnexpected`'s clousure `(HttpRequest) -> ()` is called.

Note: 
- `Routes.User.login().path` is a relative path not containing `127.0.0.1:8080`

See the mobile app located in folder `example` for more details.

### SkyUITestCase - User Interface test example
In the context of UI test a mobile app (MA) can be represented as a black box (see Input/Output) defined by its own inputs and outputs. 

![Input/Output](https://user-images.githubusercontent.com/51656240/95301424-e1ad5000-0880-11eb-8b42-007bda2722ae.png)

MA behavior depends on user activity (user gestures), BE state (BE http responses) and MA storage (Persistence Storage). On the other side, the behavior of MA can be described by the UI element displayed to the user and by the http requests executed so far by MA. UI Tests verify the correctness of MA's behavior defining asserts on inputs and/or outputs of the black box. 

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
The example below gives you an idea of how to use DSL for testing in your test. Suppose a PetStore app composed by two screens/views:
![client-lib-android-test-foundation](https://user-images.githubusercontent.com/51656240/160416057-0c3e4935-a406-4efa-8e27-58c8198853ef.png)
The behaviour "Display a list of pets after login" can described and tested with the following UI test:
```swift 
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
```
In the "Given" section we defined http mock responses required by the app, in the "When" section the app is launched and the "Login" button is tapped after user credentials are typed.
Finally in the "Then" section we assert the existence in the view hierarchy of two pets returned by the mock server.

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

## FAQ
### - How can I enable/disable breakpoints for UI tests in Xcode?
From "Edit scheme...":
![Enable/Disable Breakpoints](https://user-images.githubusercontent.com/51656240/129052171-f7597352-0087-4b3e-b8eb-f5863dd6398f.png)

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
