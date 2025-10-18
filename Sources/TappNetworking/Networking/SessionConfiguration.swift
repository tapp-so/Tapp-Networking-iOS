import Foundation

public typealias Percentage = Double
public typealias ProgressDelegate = URLSessionDelegate
public typealias ProgressHandler = (Percentage) -> Void

public protocol SessionConfigurationProtocol: URLSessionTaskDelegate {
    var configuration: URLSessionConfiguration { get }
}

public final class SessionConfiguration: NSObject, SessionConfigurationProtocol {
    public let configuration: URLSessionConfiguration

    public init(configuration: URLSessionConfiguration = .default) {
        self.configuration = configuration
        super.init()
    }
}
