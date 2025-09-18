//
//  URLSession+Protocols.swift
//

import Foundation

public typealias VoidCompletion = (_ result: Result<Void, Error>) -> Void
public typealias NetworkServiceCompletion = (_ result: Result<Data, Error>) -> Void
public typealias DataTaskCompletion = (Data?, URLResponse?, Error?) -> Void

public protocol URLSessionDataTaskProtocol {
    var identifier: Int { get }
    func resume()
    func cancel()
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {
    public var identifier: Int {
        return taskIdentifier
    }
}

public protocol URLSessionProtocol {
    func internalDataTask(with request: URLRequest, taskCompletion: @escaping DataTaskCompletion) -> URLSessionDataTaskProtocol
}

extension URLSession: URLSessionProtocol {
    public func internalDataTask(with request: URLRequest, taskCompletion: @escaping DataTaskCompletion) -> URLSessionDataTaskProtocol {
        return dataTask(with: request) { (data, response, error) in
            taskCompletion(data, response, error)
        }
    }
}
