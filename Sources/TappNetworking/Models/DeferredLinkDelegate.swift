import Foundation

public protocol DeferredLinkDelegate: AnyObject {
    func didReceiveDeferredLink(_ url: URL)
}
