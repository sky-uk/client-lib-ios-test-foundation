//
// ApiResponse.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


public struct ApiResponse: Codable, Hashable {

    public let code: Int?

    public let type: String?

    public let message: String?

    public init(code: Int? = nil, type: String? = nil, message: String? = nil) { 
        self.code = code
        self.type = type
        self.message = message
    }

}