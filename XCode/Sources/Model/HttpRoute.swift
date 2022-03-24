import Foundation

public struct HttpRoute {
    public let endpoint: HttpEndpoint
    public let response: HttpResponse
    public let sleepDelay: UInt32?
    
    public init(endpoint: HttpEndpoint, response: HttpResponse, sleepDelay: UInt32? = nil) {
        self.endpoint = endpoint
        self.response = response
        self.sleepDelay = sleepDelay
    }
}
