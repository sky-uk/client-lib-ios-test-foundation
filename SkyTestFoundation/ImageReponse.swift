import Foundation
import Swifter

struct ImageReponse {
    let path: String
    let properties: ((Swifter.HttpRequest) -> ImageProperties)?
}


