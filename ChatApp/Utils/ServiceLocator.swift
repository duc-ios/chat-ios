//
//  ServiceLocator.swift
//  ChatApp
//
//  Created by Duc on 22/8/24.
//

import Foundation

enum ServiceLocator {
    static var map = [String: Any]()

    static subscript<T: Any>(_: T.Type) -> T? {
        get {
            map["\(T.self)"] as? T
        }
        set {
            map["\(T.self)"] = newValue
        }
    }
}
