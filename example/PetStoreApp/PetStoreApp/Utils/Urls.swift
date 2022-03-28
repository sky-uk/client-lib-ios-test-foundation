import Foundation

struct Urls {

    static func baseUrl() -> URL {
        URL(string: "https://petstore.swagger.io/v2")!.replaceHostnameWithLocalhostIfUITestIsRunning()
    }

}
