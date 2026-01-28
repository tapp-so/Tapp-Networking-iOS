import Foundation

@objc
public final class TappConfiguration: NSObject, Codable {
    public static func == (lhs: TappConfiguration, rhs: TappConfiguration) -> Bool {
        let equalNonOptionalValues = lhs.authToken == rhs.authToken && lhs.env == rhs.env && lhs.tappToken == rhs.tappToken && lhs.affiliate == rhs.affiliate

        let lhsHasAppToken = lhs.appToken != nil
        let rhsHasAppToken = rhs.appToken != nil

        var appTokensEqual: Bool = false

        if let lhsAppToken = lhs.appToken, let rhsAppToken = rhs.appToken {
            appTokensEqual = lhsAppToken == rhsAppToken
        } else {
            if !lhsHasAppToken, !rhsHasAppToken {
                appTokensEqual = true
            }
        }

        let lhsHasDeviceID = lhs.deviceID != nil
        let rhsHasDeviceID = rhs.deviceID != nil
        
        var deviceIDsEqual: Bool = false
        
        if let lhsDeviceID = lhs.deviceID, let rhsDeviceID = rhs.deviceID {
            deviceIDsEqual = lhsDeviceID == rhsDeviceID
        } else {
            if !lhsHasDeviceID, !rhsHasDeviceID {
                deviceIDsEqual = true
            }
        }

        return equalNonOptionalValues && appTokensEqual && deviceIDsEqual
    }

    public let authToken: String
    public let env: Environment
    public let tappToken: String
    public let affiliate: Affiliate
    public let bundleID: String?
    private(set) public var deviceID: String?
    private(set) public var isDeviceActive: Bool = false
    private(set) public var isAlreadyVerified: Bool = false
    private(set) public var appToken: String?
    private(set) public var hasProcessedReferralEngine: Bool = false
    private(set) public var originURL: URL?
    private(set) public var originAttributedTappURL: URL?
    private(set) public var originInfluencer: String?
    private(set) public var originData: [String: String?]?

    @objc
    public init(
        authToken: String,
        env: Environment,
        tappToken: String,
        affiliate: Affiliate,
        bundleID: String? = nil
    ) {
        self.authToken = authToken
        self.env = env
        self.tappToken = tappToken
        self.affiliate = affiliate
        self.bundleID = bundleID ?? Bundle.main.bundleIdentifier
        super.init()
    }

    @objc
    public init(
        authToken: String,
        env: String,
        tappToken: String,
        affiliateName: String,
        bundleID: String? = nil
    ) {
        self.authToken = authToken
        self.env = env.toEnvironment
        self.tappToken = tappToken
        self.affiliate = affiliateName.toAffiliate
        self.bundleID = bundleID ?? Bundle.main.bundleIdentifier
        super.init()
    }

    public func set(appToken: String) {
        self.appToken = appToken
    }

    public func set(originURL: URL) {
        self.originURL = originURL
    }

    public func set(originAttributedTappURL: URL?) {
        self.originAttributedTappURL = originAttributedTappURL
    }

    public func set(originInfluencer: String?) {
        self.originInfluencer = originInfluencer
    }

    public func set(originData: [String: String?]?) {
        self.originData = originData
    }

    public func set(hasProcessedReferralEngine: Bool) {
        self.hasProcessedReferralEngine = hasProcessedReferralEngine
    }

    public func set(deviceID: String) {
        self.deviceID = deviceID
    }

    public func set(deviceActive: Bool) {
        self.isDeviceActive = deviceActive
    }

    public func set(isAlreadyVerified: Bool) {
        switch env {
        case .production:
            if self.isAlreadyVerified == false, isAlreadyVerified == true {
                self.isAlreadyVerified = isAlreadyVerified
            }
        case .sandbox:
            self.isAlreadyVerified = isAlreadyVerified
        }
    }
}

private extension String {
    var toAffiliate: Affiliate {
        if self.lowercased() == "adjust" {
            return .adjust
        } else if self.lowercased() == "appsflyer" {
            return .appsflyer
        } else {
            return .tapp
        }
    }

    var toEnvironment: Environment {
        if self.lowercased() == "production" {
            return .production
        } else if self.lowercased() == "sandbox" {
            return .sandbox
        } else {
            return .sandbox
        }
    }
}
