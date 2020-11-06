# Sky Test Foundation [![CircleCI](https://circleci.com/gh/sky-uk/client-lib-ios-test-foundation/tree/master.svg?style=svg&circle-token=6a18106ecc99952ea6841f658f86282b5ff557f5)](https://circleci.com/gh/sky-uk/client-lib-ios-test-foundation/tree/master)
Test suite for iOS mobile applications: a collection of tools and classes to facilitate the writing of automatic tests during development of an iOS mobile application.
The suite has to parts, one for Unit testing and the other one for User Interface (or functional) tests.
## Test Environment
During tests execution, iOS Mobile App (MA) should interact with a Mock Server which appear to be the real counterparts of BE server. The framework provides a mock server that allows a tight control over what data the iOS App receives.
![](https://user-images.githubusercontent.com/51656240/94568277-9685b280-026c-11eb-80ac-d5a6d95bcdf3.png)

### Unit Test Template with SUT performing Http Requests
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
Note: `Endpoint.Selfcare.cities.urlPath` is a relative path not containing `127.0.0.1:8080`.

The test is composed by 3 sections:
- Given: mocks and http routes are defined
- When: call to method of SUT (system under test) to be tested
- Then: expected values assertions

If the execution of the method under test performs an http request not handled by the mocks server then `onUnexpected`'s clousure `(HttpRequest) -> ()` is called.

### UI Test Template
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
        try httpServerBuilder
            .route(try TokenManagerMocks.Auths.Response.ok200.edr())
            .route(try Mocks.Selfcare.E2EContract.Response.contractIdcmJjRzF3cTdiU3oranF3bWlLWG96dz09.edr())
            .route(try Mocks.Selfcare.E2EContract.Response.contractIdWUNjanhxMXNMZTg3emRzVURPa1ExZz09.edr())
            .route(try TokenManagerMocks.CustomersMe.Response.multiContract.edr())
            .buildAndStart()

        appLaunched(httpServerBuilder.httpServer.port, disableFeatureFlags: [.skipPreActiveCheck], persistenceStatus: .empty)
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
        tap(MSAElements.ContractSelector.mainView.tables.staticTexts["Codice cliente: 15519872"])
        tap(MSAElements.ContractSelector.mainView.staticTexts[String.msa.generics.confirm().uppercased()])
        exist(MSAElements.Alert.mainView)
        tap(MSAElements.Alert.mainButton)
        exist(MSAElements.Home.mainView)
    }
    
 }
 ```
### UI UITestHttpServerBuilder
Mock server builder to be used in UI tests.
#### func route(_ response: (endpoint: String, statusCode: Int, body: Data, responseTime: UInt32?), on: ((Swifter.HttpRequest) -> Void)? = nil) -> UITestHttpServerBuilder
Adds http route to mock server. Clousure `on` is called on main thread when a http request with path equals to `endpoint` is received by the mock server.
#### func route(endpoint: String, on: @escaping ((Swifter.HttpRequest) -> HttpResponse)) -> UITestHttpServerBuilder
Adds http route to mock server. Closure `on` id called on a background thread when a http request with path equals to `endpoint` is received by the mock server. The closure allows to return different Http responses given an http request.
#### buildAndStart(port: in_port_t = 8080, file: StaticString = #file, line: UInt = #line) throws -> HttpServer
Build all routes added so far and starts the mock server.

Example
```swift
import XCTest
import Swifter
import SkyTestFoundation
class UITests: SkyUITestCase {
    func test() throws {
        // Given
        try httpServerBuilder
            .route(endpoint: "/endpoint1", on: { (request) -> HttpResponse in
                return HttpResponse.raw(statusCode: 200, body: Data())
            })
            .buildAndStart()

        appLaunched(httpServerBuilder.httpServer.port)
        // ...
    }
}
```
 
The test is composed by 3 sections:
- Given: mocks, http routes are defined and app is launced 
- When: ui gesture are performed in order to navigate to the view to be tested 
- Then: assertions on ui element of the view (to be tested)

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
### UI XCTAssert Extensions
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
