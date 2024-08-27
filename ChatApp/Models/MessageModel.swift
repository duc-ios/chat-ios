//
//  MessageModel.swift
//  ChatApp
//
//  Created by Duc on 21/8/24.
//

import ExyteChat
import Foundation

struct MessageModel {
    let id: Int
    let text: String
    let sender: UserModel?
    let conversation: ConversationModel?
    let createdAt: Date

    var triggerRedraw: UUID?

    init(id: Int, text: String, sender: UserModel? = nil, conversation: ConversationModel? = nil, createdAt: Date, triggerRedraw _: UUID? = nil) {
        self.id = id
        self.text = text
        self.sender = sender
        self.conversation = conversation
        self.createdAt = createdAt
    }
}

extension MessageModel: Hashable, Identifiable {}

extension MessageModel: Codable {
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        sender = try container.decodeIfPresent(UserModel.self, forKey: .sender)
        conversation = try container.decodeIfPresent(ConversationModel.self, forKey: .conversation)
        createdAt = try ISO8601DateFormatter().date(from: container.decodeIfPresent(String.self, forKey: .createdAt) ?? "") ?? Date()
    }
}

extension MessageModel {
    func toMessage() -> Message? {
        guard let sender else { return nil }
        var message = Message(
            id: id.stringValue,
            user: .init(
                id: sender.id.stringValue,
                name: sender.username,
                avatarURL: sender.avatar,
                isCurrentUser: sender.isMe
            ),
            text: text
        )
        message.triggerRedraw = triggerRedraw
        return message
    }
}
