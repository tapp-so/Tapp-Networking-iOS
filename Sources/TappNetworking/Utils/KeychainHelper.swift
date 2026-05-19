//
//  KeychainHelper.swift
//  Tapp
//
//  Created by Nikolaos Tseperkas on 9/11/24.
//

import Foundation
import Security

public protocol KeychainHelperProtocol {
    func save(configuration: TappConfiguration)
    func set(bundleID: String?)
    var currentEnvironment: Environment { get }
    func set(environment: Environment)
    var config: TappConfiguration? { get }
    var hasConfig: Bool { get }
}

public final class KeychainHelper: KeychainHelperProtocol {
    enum StorageError: Error {
        case noValue
    }

    public static let shared = KeychainHelper()
    private var bundleID: String?
    private var environment: Environment = .sandbox

    public convenience init() {
        self.init(keychainTool: KeychainTool())
    }

    let keychainTool: KeychainToolProtocol
    init(keychainTool: KeychainToolProtocol = KeychainTool()) {
        self.keychainTool = keychainTool
    }

    public var currentEnvironment: Environment {
        return environment
    }

    @objc
    public func set(bundleID: String?) {
        guard self.bundleID == nil else {
            TappLog.logInfo(message: "⚠️ Keychain: bundleID already set to '\(self.bundleID ?? "nil")', ignoring new value '\(bundleID ?? "nil")'",
                            environment: environment,
                            context: "Keychain")
            return
        }
        self.bundleID = bundleID
        TappLog.logInfo(message: "✅ Keychain: bundleID set to '\(bundleID ?? "nil")'",
                        environment: environment,
                        context: "Keychain")
    }

    @objc
    public func set(environment: Environment) {
        self.environment = environment
        TappLog.logInfo(message: "✅ Keychain: environment set to '\(environment.rawValue)'",
                        environment: environment,
                        context: "Keychain")
    }

    private var keychainKey: String {
        let key = "tapp_c"
        if let bundleID {
            return "\(key)_\(bundleID)_\(environment.storageKey)"
        }
        return key
    }

    public func save(configuration: TappConfiguration) {
        if let config, let url = config.originURL {
            configuration.set(originURL: url)
        }

        save(key: keychainKey, codable: configuration)
    }

    public var config: TappConfiguration? {
        let result = get(key: keychainKey, type: TappConfiguration.self) as? TappConfiguration

        return result
    }

    public var hasConfig: Bool {
        return config != nil
    }

    private func save(key: String, codable: any Codable) {
        keychainTool.save(key: key, codable: codable)
    }

    private func get<T: Decodable>(key: String, type: T.Type, decodingStrategy: JSONDecoder.DateDecodingStrategy = .iso8601) -> (any Decodable)? {
        return keychainTool.get(key: key, type: type, decodingStrategy: decodingStrategy)
    }

    func delete(key: String) {
        return keychainTool.delete(key: key)
    }
}

protocol KeychainToolProtocol {
    func save(key: String, codable: any Codable)
    func get<T: Decodable>(key: String, type: T.Type, decodingStrategy: JSONDecoder.DateDecodingStrategy) -> Decodable?
    func delete(key: String)
}

final class KeychainTool: KeychainToolProtocol {

    private let service = "com.tapp.sdk"

    func save(key: String, codable: any Codable) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(codable) else {
            return
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    func get<T: Decodable>(key: String, type: T.Type, decodingStrategy: JSONDecoder.DateDecodingStrategy) -> Decodable? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            return nil
        }

        guard let data = result as? Data else {
            return nil
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = decodingStrategy

        do {
            let decoded = try decoder.decode(type, from: data)
            return decoded
        } catch {
            return nil
        }
    }

    func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)
    }

    private func statusDescription(_ status: OSStatus) -> String {
        switch status {
        case errSecSuccess:             return "(success)"
        case errSecItemNotFound:        return "(item not found)"
        case errSecDuplicateItem:       return "(duplicate item)"
        case errSecParam:               return "(bad parameter)"
        case errSecAllocate:            return "(allocation failure)"
        case errSecNotAvailable:        return "(not available)"
        case errSecAuthFailed:          return "(auth failed)"
        case -34018:                    return "(missing entitlement — check keychain-access-groups)"
        case -25243:                    return "(no access for item — check kSecAttrAccessible)"
        case -25308:                    return "(interaction not allowed — device may be locked)"
        default:                        return "(unknown — look up OSStatus \(status))"
        }
    }
}

private extension Environment {
    var storageKey: String {
        switch self {
        case .sandbox:
            return "s"
        case .production:
            return "p"
        }
    }
}
