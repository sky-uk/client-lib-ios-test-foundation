# Sky Test Foundation [![CircleCI](https://circleci.com/gh/sky-uk/client-lib-ios-test-foundation/tree/master.svg?style=svg&circle-token=6a18106ecc99952ea6841f658f86282b5ff557f5)](https://circleci.com/gh/sky-uk/client-lib-ios-test-foundation/tree/master)
Test suite for iOS mobile applications: a collection of tools and classes to facilitate the writing of automatic tests during development of an iOS mobile application.
The suite has to parts, one for Unit testing and the other one for User Interface (or functional) tests.
## Test Environment
During test execution iOS App should interact with a Mock Server which appear to be the real counterparts of BE server. The framework provides a mock server that allows a tight control over what data the iOS App receives, making it much more amenable to testing.
![](https://user-images.githubusercontent.com/51656240/94526385-bc439500-0235-11eb-8935-42123d5b4430.png)

### Unit Test Template with SUT performing Http Requests
```swift
class CustomerRepositoryTests: SkyUnitTestCase {

    var sut: AddressServices!

     override func setUp() {
        super.setUp()
        let sdk = FakeMySkyAppSDK.localhost()
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
Note: `Endpoint.Selfcare.cities.urlPath` is a relative path not containing `localhost:8080`.
