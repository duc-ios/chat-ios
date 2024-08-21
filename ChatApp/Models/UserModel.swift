//
//  UserModel.swift
//  ChatApp
//
//  Created by Duc on 21/8/24.
//

import ExyteChat
import Foundation

struct UserModel: Codable, Hashable, Identifiable {
    let id: Int
    var socketId: String?
    var jwt: String?
    let username: String
    let avatar: URL?
    var isActive: Bool = false

    enum CodingKeys: CodingKey {
        case id,
             socketId,
             jwt,
             username,
             avatar
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(.id)
        self.socketId = try container.decodeIfPresent(.socketId)
        self.jwt = try container.decodeIfPresent(.jwt)
        self.username = try container.decode(.username)
        if let avatar: Avatar = try? container.decode(.avatar) {
            self.avatar = AppEnvironment.baseUrl.appending(path: avatar.formats.thumbnail.url)
        } else if let avatar: String = try? container.decode(.avatar) {
            self.avatar = AppEnvironment.baseUrl.appending(path: avatar)
        } else {
            self.avatar = nil
        }
    }

    func toUser() -> User {
        User(
            id: id.stringValue,
            name: username,
            avatarURL: avatar,
            isCurrentUser: id == UserSettings.me?.id
        )
    }
}

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
