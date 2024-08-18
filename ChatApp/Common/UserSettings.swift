//
//  UserSettings.swift
//  StrapiChat
//
//  Created by Duc on 18/8/24.
//

import ExyteChat
import Foundation
import SwiftUI

enum UserSettings {
    static let baseUrl = URL(string: Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as! String)!
    static var isLoggedIn: Bool {
        if let me = UserSettings.me, me.jwt.isNotNilOrBlank {
            return true
        }
        return false
    }

    @AppStorage("me")
    private static var _me: Data?
    static var me: UserModel? {
        get {
            if let _me {
                return try? UserModel(_me)
            }
            return nil
        }
        set {
            _me = try? newValue?.rawData()
        }
    }
}
