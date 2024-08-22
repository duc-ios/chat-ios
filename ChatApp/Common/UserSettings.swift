//
//  UserSettings.swift
//  StrapiChat
//
//  Created by Duc on 18/8/24.
//

import Foundation
import SwiftUI

class UserSettings: ObservableObject {
    var isLoggedIn: Bool {
        if let me = me, me.jwt.isNotNilOrBlank {
            return true
        }
        return false
    }

    @UserDefaultStorage(key: "me", default: nil)
    var me: UserModel?

    @MainActor
    func logout() {
        guard isLoggedIn else { return }
        me = nil
        ServiceLocator[Router.self]?.popToRoot()
    }
}

enum AppEnvironment {
    static subscript<T>(_ key: String) -> T? {
        Bundle.main.object(forInfoDictionaryKey: key) as? T
    }

    static let BASE_URL = "BASE_URL"
    static let baseUrl = URL(string: AppEnvironment[BASE_URL]!)!
}

@propertyWrapper
struct UserDefaultStorage<T: Codable> {
    private let key: String
    private let defaultValue: T

    private let userDefaults: UserDefaults

    init(key: String, default: T, store: UserDefaults = .standard) {
        self.key = key
        defaultValue = `default`
        userDefaults = store
    }

    var wrappedValue: T {
        get {
            guard let data = userDefaults.data(forKey: key) else {
                return defaultValue
            }
            let value = try? JSONDecoder().decode(T.self, from: data)
            return value ?? defaultValue
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            userDefaults.set(data, forKey: key)
        }
    }
}
