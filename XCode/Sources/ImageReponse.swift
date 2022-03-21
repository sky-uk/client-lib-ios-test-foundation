import Foundation

struct ImageReponse {
    let path: String
    let properties: ((HttpRequest) -> ImageProperties)?
}
