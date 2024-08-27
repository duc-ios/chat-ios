//
//  UserModel.swift
//  ChatApp
//
//  Created by Duc on 21/8/24.
//

import ExyteChat
import Foundation

// MARK: - UserModel

struct UserModel {
    var id: Int = -1
    var documentId: String = ""
    var socketId: String?
    var jwt: String?
    var username: String
    var avatar: URL?
    var isActive: Bool = false
}

// MARK: Hashable, Identifiable

extension UserModel: Hashable, Identifiable {}

// MARK: Codable

extension UserModel: Codable {
    enum CodingKeys: CodingKey {
        case id,
             documentId,
             jwt,
             username,
             avatar
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(.id)
        documentId = try container.decode(.documentId)
        jwt = try container.decodeIfPresent(.jwt)
        username = try container.decode(.username)
        if let avatar: Avatar = try? container.decode(.avatar) {
            self.avatar = AppEnvironment.baseUrl.appending(path: avatar.formats.thumbnail.url)
        } else if let avatar: String = try? container.decode(.avatar) {
            self.avatar = AppEnvironment.baseUrl.appending(path: avatar)
        } else {
            avatar = nil
        }
    }

    func toUser() -> User {
        User(
            id: id.stringValue,
            name: username,
            avatarURL: avatar,
            isCurrentUser: id == ServiceLocator[UserSettings.self]?.me?.id
        )
    }
}

// MARK: - Avatar

struct Avatar: Codable {
    struct Formats: Codable {
        struct Format: Codable {
            let url: String
        }

        let large: Format
        let medium: Format
        let small: Format
        let thumbnail: Format
    }

    let formats: Formats
}
