import Foundation
import Swifter

public class HttpResponse {
    let body: Data
    let statusCode: Int
    let headers: [String : String]
    
    public init(body: Data = Data(), statusCode: Int = 200, headers: [String: String] = [:]) {
        self.body = body
        self.statusCode = statusCode
        self.headers = headers
    }
}

extension HttpResponse {
    public static func notFound() -> HttpResponse {
        return HttpResponse(statusCode: 404)
    }
    
    public static func badRequest() -> HttpResponse {
        return HttpResponse(statusCode: 400)
    }
    
    func toSwifter() -> Swifter.HttpResponse {
        return Swifter.HttpResponse.raw(statusCode, "", headers) { (writer) in
            try writer.write(self.body)
        }
    }
}

