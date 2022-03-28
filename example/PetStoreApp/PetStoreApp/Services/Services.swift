import Foundation
import PetStoreSDK
import ReactiveAPI
import RxSwift
import UIKit

class Services: ObservableObject {
    let user: UserAPI
    let pet: PetAPI
    /* FOOD ADDITIONS START
    let food: FoodAPI
    FOOD ADDITIONS END */

    init(baseUrl: URL,
         decoder: JSONDecoder = JSONDecoder(),
         encoder: JSONEncoder = JSONEncoder(),
         urlSession: Reactive<URLSession> = URLSession(configuration: URLSessionConfiguration.default,
                                                       delegate: nil,
                                                       delegateQueue: nil).rx,
         interceptors: [ReactiveAPIRequestInterceptor] = [JSONInterceptor()]) {

        user = UserAPI(session: urlSession, decoder: decoder, encoder: encoder, baseUrl: baseUrl)
        user.requestInterceptors = interceptors

        pet = PetAPI(session: urlSession, decoder: decoder, encoder: encoder, baseUrl: baseUrl)
        pet.requestInterceptors = interceptors

        /* FOOD ADDITIONS START
        food = FoodAPI(session: urlSession, decoder: decoder, encoder: encoder, baseUrl: baseUrl)
        food.requestInterceptors = interceptors
        FOOD ADDITIONS END */
    }
}

public class JSONInterceptor: ReactiveAPIRequestInterceptor {
    public func intercept(_ request: URLRequest) -> URLRequest {
        var mutableRequest = request
        mutableRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        mutableRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        return mutableRequest
    }
}
