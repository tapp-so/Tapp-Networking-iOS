import Foundation

public protocol NetworkClientProtocol {
    @discardableResult func execute(request: URLRequest, completion: NetworkServiceCompletion?) -> URLSessionDataTaskProtocol?
    @discardableResult func executeAuthenticated(request: URLRequest, completion: NetworkServiceCompletion?) -> URLSessionDataTaskProtocol?
}

public final class NetworkClient: NetworkClientProtocol {
    let sessionConfiguration: SessionConfigurationProtocol
    let session: URLSessionProtocol
    let keychainHelper: KeychainHelperProtocol

    public init(sessionConfiguration: SessionConfigurationProtocol,
                keychainHelper: KeychainHelperProtocol = KeychainHelper.shared,
                session: URLSessionProtocol? = nil) {
        self.sessionConfiguration = sessionConfiguration
        self.keychainHelper = keychainHelper
        self.session = session ?? URLSession(configuration: sessionConfiguration.configuration,
                                             delegate: sessionConfiguration,
                                             delegateQueue: .main)
    }

    @discardableResult public func execute(request: URLRequest, completion: NetworkServiceCompletion?) -> URLSessionDataTaskProtocol? {
        let dataTask: URLSessionDataTaskProtocol = session.internalDataTask(with: request) { (data, response, error) in
            if let error = error {
                completion?(Result.failure(error))
            } else if let data = data {
                if let serverError = data.serverError {
                    completion?(Result.failure(serverError))
                } else {
                    completion?(Result.success(data))
                }
            }
        }
        dataTask.resume()

        return dataTask
    }

    @discardableResult public func executeAuthenticated(request: URLRequest, completion: NetworkServiceCompletion?) -> URLSessionDataTaskProtocol? {
        guard let config = keychainHelper.config else {
            completion?(Result.failure(TappServiceError.unauthorized))
            return nil
        }

        return execute(request: request.apply(token: config.authToken), completion: completion)
    }
}

extension Data {
    public var isError: Bool {
        return serverError != nil
    }

    public var serverError: ServerError? {
        return try? JSONDecoder().decode(ServerError.self, from: self)
    }

    public func prettyPrinted() {
        if let json = try? JSONSerialization.jsonObject(with: self, options: .mutableContainers),
           let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
            print(String(decoding: jsonData, as: UTF8.self))
        } else {
            print("json data malformed")
        }
    }
}

extension URLRequest {
    public func apply(token: String) -> URLRequest {
        var request = self

        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return request
    }
}

extension URL {
    public func param(for key: String) -> String? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true) else { return nil }
        guard let queryItems = components.queryItems?.toDictionary else { return nil }
        return queryItems[key]?.value
    }
}

extension Array where Element == URLQueryItem {
    public var toDictionary: [String: URLQueryItem] {
        var dict: [String: URLQueryItem] = [:]

        forEach { item in
            dict[item.name] = item
        }

        return dict
    }
}
