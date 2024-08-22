//
//  UserModel+Extensions.swift
//  StrapiChat
//
//  Created by Duc on 19/8/24.
//

extension UserModel {
    var isMe: Bool {
        if let me = ServiceLocator[UserSettings.self]?.me {
            return id == me.id
        }
        return false
    }
}
