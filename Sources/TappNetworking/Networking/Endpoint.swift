//
//  Endpoint.swift
//  Tapp
//
//  Created by Alex Stergiou on 19/11/2024.
//

import Foundation

public enum APIPath: String {
    case id
    case influencer
    case add
    case deeplink
    case secrets
    case event
    case linkData

    public var prefixInfluencer: String {
        return rawValue.prefixInfluencer
    }

    public var prefixAdd: String {
        return rawValue.prefixAdd
    }
}

extension String {

    public var prefixInfluencer: String {
        return prefix(APIPath.influencer.rawValue)
    }

    public var prefixAdd: String {
        return prefix(APIPath.add.rawValue)
    }

    public func prefix(_ value: String) -> String {
        return "\(value)/" + self
    }
}

public enum HTTPMethod: String, CaseIterable {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}

public extension Environment {
    var baseURL: String {
        switch self {
        case .sandbox:
            return "https://api.staging.tapp.so/v1/ref"
        case .production:
            return "https://api.tapp.so/v1/ref"
        }
    }
}

public enum BaseURL {
    static func value(for environment: Environment) -> String {
        return "\(environment.baseURL)"
    }
}

public protocol Endpoint {
    var httpMethod: HTTPMethod { get }
    var path: String { get }
    var request: URLRequest? { get }
    var url: URL? { get }
}

public extension Endpoint {
    var defaultRequest:URLRequest? {
        return EndpointRequestProvider().request(url: self.url, httpMethod: self.httpMethod)
    }

    var request: URLRequest? {
        return defaultRequest
    }

    func request(encodable: Encodable) -> URLRequest? {
        var request = defaultRequest
        let encoder = JSONEncoder()
        request?.httpBody = try? encoder.encode(encodable)
        return request
    }

    func request(encodable: Encodable, accessToken: String) -> URLRequest? {
        var request = request(encodable: encodable)

        request?.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        return request
    }

    var url: URL? {
        return defaultURL
    }

    var defaultURL: URL? {

        let environment: Environment = KeychainHelper.shared.config?.env ?? .sandbox
        let string = BaseURL.value(for: environment) + "/" + self.path

        return URL(string: string)
    }

    func url(id: UUID) -> URL? {
        guard let url = defaultURL else { return nil }
        var components = URLComponents(string: url.absoluteString)
        components?.queryItems = [URLQueryItem(name: APIPath.id.rawValue, value: id.uuidString)]
        return components?.url
    }
}

struct EndpointRequestProvider {
    func request(url: URL?, httpMethod: HTTPMethod, body: Data? = nil) -> URLRequest? {
        guard let url = url else {
            return nil
        }
        var headers: [String: String] = [:] // Add any common headers here.
        headers["Content-Type"] = "application/json"
        var urlRequest: URLRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.httpMethod = httpMethod.rawValue
        urlRequest.httpBody = body

        return urlRequest
    }
}
