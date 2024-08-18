//
//  UserModel.swift
//  ChatApp
//
//  Created by Duc on 21/8/24.
//

import ExyteChat
import Foundation

struct UserModel: Codable, Hashable, Identifiable {
    let id: String
    let socketId: String?
    var jwt: String?
    let username: String
    let avatar: URL?

    enum CodingKeys: CodingKey {
        case id,
             socketId,
             jwt,
             username,
             avatar
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let id = try? container.decode(Int.self, forKey: .id) {
            self.id = String(id)
        } else {
            self.id = try String(container.decode(String.self, forKey: .id))
        }
        self.socketId = try? container.decode(String.self, forKey: .socketId)
        self.jwt = try? container.decode(String.self, forKey: .jwt)
        self.username = try container.decode(String.self, forKey: .username)
        let avatar = try? container.decode(Avatar.self, forKey: .avatar)
        if let avatar {
            self.avatar = UserSettings.baseUrl.appending(path: avatar.formats.thumbnail.url)
        } else {
            self.avatar = nil
        }
    }

    func toUser() -> User {
        User(
            id: id,
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
