//
// Category.swift
//
// Generated by swagger-codegen
// https://github.com/swagger-api/swagger-codegen
//

import Foundation


public struct Category: Codable, Hashable {

    public let _id: Int?

    public let name: String?

    public init(_id: Int? = nil, name: String? = nil) { 
        self._id = _id
        self.name = name
    }

    public enum CodingKeys: String, CodingKey { 
        case _id = "id"
        case name
    }

}