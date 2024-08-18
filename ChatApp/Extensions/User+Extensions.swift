//
//  User+Extensions.swift
//  StrapiChat
//
//  Created by Duc on 19/8/24.
//

import ExyteChat

extension User {
    var isMe: Bool {
        if let me = UserSettings.me {
            return id == me.id
        }
        return false
    }
}
