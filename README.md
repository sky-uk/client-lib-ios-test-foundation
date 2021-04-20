# Sky Test Foundation [![CircleCI](https://circleci.com/gh/sky-uk/client-lib-ios-test-foundation/tree/master.svg?style=svg&circle-token=6a18106ecc99952ea6841f658f86282b5ff557f5)](https://circleci.com/gh/sky-uk/client-lib-ios-test-foundation/tree/master)
Test suite for iOS mobile applications: a collection of tools and classes to facilitate the writing of automatic tests during development of an iOS mobile application.
The suite has to parts, one for Unit testing and the other one for User Interface (or functional) tests.
## Test Environment
During tests execution, iOS Mobile App (MA) should interact with a Mock Server which appear to be the real counterparts of BE server. The framework provides a mock server that allows a tight control over what data the iOS App receives.
![](https://user-images.githubusercontent.com/51656240/94568277-9685b280-026c-11eb-80ac-d5a6d95bcdf3.png)
During the execution of the tests the MA must forward http requests to http://127.0.0.1:8080.

## SkyUITestCase/SkyUTTestCase primary classes for defining test cases
SkyUITestCase and SkyUTTestCase classes extend XCTestCase and define a mock server. Use SkyUITestCase and SkyUTTestCase for UI and Unit test cases respectively.

### SkyUTTestCase - Unit Test example with SUT performing Http Requests
The goal of this kind of unit test is to verify the correctness of the http requests performed by the MA. The `httpServerBuilder` object allows to define the state of the mock server as a set of http routes. Note `FakeMySkyAppSDK.localhost()` in the `setupUp()` forwards http request performed by MA to localhost.
See [Unit Test Overview](https://developer.bskyb.com/wiki/pages/viewpage.action?spaceKey=DPTECH&title=Unit+testing) for more deatil on unit testing approach in Sky.
```swift
import XCTest
import Swifter
import SkyTestFoundation

class CustomerRepositoryTests: SkyUnitTestCase {

    var sut: AddressServices!

     override func setUp() {
        super.setUp()
        let sdk = FakeMySkyAppSDK.localhost()     // forwards MSA's http requests to 127.0.0.0:8080 
        sdk.services.selfCare.customerRepository.clearAll(removingUserSelections: true)
        sut = sdk.services.selfCare.address
    }
    
    func testGetNormalizedCities() throws {
        // Given
        let query = "Milano"
        let citiesResponse = [City.mock(egonId: String.mock(), name: String.mock(), province: String.mock())]

        try httpServerBuilder.route(Endpoint.Selfcare.cities.urlPath) { (request, callCount) -> (HttpResponse) in
            XCTAssertEqual(request.method, ReactiveAPIHTTPMethod.get.rawValue)
            XCTAssertEqual(request.queryParam("q"), query)
            XCTAssertEqual(request.headers["egon-route"], true.stringValue)
            let data = try! JSONHelper.encode(value: citiesResponse)
            return HttpResponse.ok(HttpResponseBody.data(data))

        }.onUnexpected { (request) in

            UnexepctedRequestFail(request)

        }.buildAndStart()
    
        // When
        let streamed = try sut.getNormalizedCities(query: query).toBlocking().single()
        // Then
        XCTAssertNotNil(streamed)
        XCTAssertEqual(streamed.first, citiesResponse.first)
    }
}
```

where 

```swift
func UnexepctedRequestFail(_ request: Swifter.HttpRequest, file: StaticString = #file, line: UInt = #line) {
    XCTFail("Url request not stubbed: \(String(describing: request.path))", file: file, line: line)
}
```
The test is composed by 3 sections:
- Given: mocks and http routes are defined
- When: call to method of SUT (system under test) to be tested
- Then: expected values assertions
If the execution of the method under test performs an http request not handled by the mocks server then `onUnexpected`'s clousure `(HttpRequest) -> ()` is called.

Note: 
- `Endpoint.Selfcare.cities.urlPath` is a relative path not containing `127.0.0.1:8080`

### SkyUITestCase - User Interface test example
In the context of UI test a mobile app (MA) can be represented as a black box (see Input/Output) defined by its own inputs and outputs. 

![Input/Output](https://user-images.githubusercontent.com/51656240/95301424-e1ad5000-0880-11eb-8b42-007bda2722ae.png)

MA behaviour depends on user activity (user gestures), BE state (BE http responses) and MA storage (Persistence Storage). On the other side, the behaviour of MSA can be described by the view hierarchy displayed to the user and by the http requests executed so far by MSA. UI Tests verify the correctness of MSA's behaviour defining asserts on inputs and/or ouputs of the black box. 

```swift
import XCTest
import Swifter
import SkyTestFoundation

class LoginTests: SkyUITestCase {

    func testSelectSignedContractGivenContractNotActivated() throws {
        // Given
        httpServerBuilder
            .route(TokenManagerMocks.Auths.Response.ok200.edr())
            .route(Mocks.Selfcare.E2EContract.Response.contractIdcmJjRzF3cTdiU3oranF3bWlLWG96dz09.edr())
            .route(Mocks.Selfcare.E2EContract.Response.contractIdWUNjanhxMXNMZTg3emRzVURPa1ExZz09.edr())
            .route(TokenManagerMocks.CustomersMe.Response.multiContract.edr())
            .buildAndStart()

        appLaunched(disableFeatureFlags: [.skipPreActiveCheck], persistenceStatus: .empty)
        // When
        tap(MSAElements.Welcome.accediButton)

        tap(MSAElements.Login.mainView.scrollViews.otherElements.textFields[String.msa.login.userPlaceholder()])
        MSAElements.Login.mainView.typeText(testCredentialUsername)

        tap(MSAElements.Login.mainView.scrollViews.otherElements.secureTextFields[String.msa.generics.password()])
        MSAElements.Login.mainView.typeText(testCredentialPassword)

        tap(MSAElements.Login.loginButton)
        tap(MSAElements.Alert.secondaryButton, "Biometric alert")
        tap(MSAElements.Alert.mainButton)

        exist(MSAElements.AlternativeHome.mainView)
        // Then
        tap(MSAElements.Home.profileButton)
        exist(MSAElements.ContractSelector.mainView)
        tap(MSAElements.ContractSelector.mainView.withText("Codice cliente: 15519872"))
        tap(MSAElements.ContractSelector.mainView.withText(String.msa.generics.confirm().uppercased()))
        exist(MSAElements.Alert.mainView)
        tap(MSAElements.Alert.mainButton)
        exist(MSAElements.Home.mainView)
    }
    
 }
 ``` 

### Mock Server Builders
SkyUITestCase and SkyUTTestCase provide mock server builder to easy the definition of the mock server routes. Builder can be accessed using the variable `httpServerBuilder` defined in SkyUITestCase and SkyUTTestCase.

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

#### API - UT mock server builder
Available methods of `httpServerBuilder`:

```swift
func route(_ endpoint: String, _ completion: @escaping (HttpRequest, Int) -> (HttpResponse)) -> UTHttpServerBuilder
```
Adds http route to mock server. Clousure `on` returns the Http reponses associated to the `endpoint`. The first argument of the closure is the http request received by the mock server and the second one contains the number of http request received so far by the mock server.

```swift
func onUnexpected(_ asserts: @escaping (HttpRequest) -> Void) -> UTHttpServerBuilder
```
If the SUT performs an http request not handled by the mock server then the closure ```asserts``` is called. The argument of the assert contains the
http request not handled by the mock server.

```swift
func buildAndStart(port: in_port_t = 8080, forceIPv4: Bool = false, priority: DispatchQoS.QoSClass = .userInteractive) throws -> HttpServer
```
Build all routes added so far and starts the mock server.

### XCTAssert Extensions
Useful extensions of assertions defined in XCTest framework.

#### XCTAssertURLEqual(_ url1, _ url2, ignores, ...)
Asserts that two http urls are equals. Use `ignores` parameter to skip comparisions between specific components of url1 and url2.

Example
```swift 
XCTAssertURLEqual("http://www.sky.com/path1", "http://www.sky.com/path1")
XCTAssertURLEqual("http://www.sky.com/path1", "http://xxx.xxx.xxx/path1", ignores: [.host])
XCTAssertURLEqual("http://www.sky.com/path1", "http://www.sky.com/path2", ignores: [.path])

XCTAssertURLEqual("http://www.sky.com?name1=value1", "http://www.sky.com?name1=value1")
XCTAssertURLEqual("http://www.sky.com?name2=value2&name1=value1", "http://www.sky.com?name1=value1&name2=value2")
XCTAssertURLEqual("http://www.sky.com", "http://www.sky.com?q1=value1", ignores: [.queryParameters])
```
## DSL for UI Testing
In the context of user interface test we have notice that a behaviour of a mobile application can be described with a language composed by some verbs & nouns.

![some_verbs_sodalizio](https://user-images.githubusercontent.com/51656240/115408436-22533200-a1f1-11eb-9ae0-7b5eb9ad4fb1.jpg)


Useful extensions of assertions defined in XCTest framework that can be used in UI tests.
The following custom assertions are wrappers of events defined in `XCUIElement` like `tap()`. The custom assertions wait for any element to appear before firing the wrapped event.
The effect of using custom assertions is to reduce flakiness of ui test execution.
#### exist(_ element)
Determines if the element exists.
#### notExist(_ element)
Determines if the element NOT exists.
#### tap(_ element)
Sends a tap event to a hittable point computed for the element.
#### isEnabled(_ element)
Determines if the element is enabled for user interaction.
#### isNotEnabled(_ elemenyt)
Determines if the element is NOT enabled for user interaction.
#### isRunningOnSimulator() -> Bool
Returns true if ui test is running on iOS simulator. It can be used in conjunction with `XCTSkipIf/1` in order to skip the execution of a ui test if on iOS simulator.

### Mocks - Random data generators
The framework provides mocks for built-in data types of Swift. In mock testing, the dependencies are replaced with objects that simulate the behaviour of the real ones. The purpose of mocking is to isolate and focus on the code being tested and not on the behaviour or state of external dependencies.
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
### Carthage
Add SkyTestFoundation to your Cartfile.private

```github "sky-uk/client-lib-ios-test-foundation"```

and in the test target add the following script

![image](https://user-images.githubusercontent.com/51656240/104758256-710aaf00-575e-11eb-9559-84b3f39b58fb.png)

### Swift Package Manager
SPM is supported too

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
