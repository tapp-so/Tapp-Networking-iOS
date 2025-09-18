//
//  Errors.swift
//

import Foundation

public enum TappServiceError: Error {
    case invalidRequest
    case invalidURL
    case invalidData
    case invalidID
    case unauthorized
    case unprocessableEntity
    case noNetwork
    case notFound
}

public struct ServerError: Error, Codable, Equatable {
    public let error: Bool
    public let reason: String

    public init(error: Bool, reason: String) {
        self.error = error
        self.reason = reason
    }

    public enum ErrorType: String {
        case other
    }

    public var type: ErrorType {
        return ErrorType(rawValue: reason) ?? .other
    }
}
