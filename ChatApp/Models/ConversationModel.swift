//
//  ConversationModel.swift
//  StrapiChat
//
//  Created by Duc on 19/8/24.
//

import Foundation

class ConversationModel: Codable {
    var id: Int
    var name: String?
    var refId: String
    var participants: [UserModel]?
    var lastMessage: MessageModel?
    var createdAt: Date

    static func == (lhs: ConversationModel, rhs: ConversationModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        [any Hashable](arrayLiteral:
            id,
            name,
            refId,
            participants,
            lastMessage,
            createdAt).forEach { hasher.combine($0) }
    }

    init(id: Int, name: String? = nil, refId: String, participants: [UserModel]? = nil, lastMessage: MessageModel? = nil, createdAt: Date) {
        self.id = id
        self.name = name
        self.refId = refId
        self.participants = participants
        self.lastMessage = lastMessage
        self.createdAt = createdAt
    }

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        refId = try container.decode(String.self, forKey: .refId)
        participants = try container.decodeIfPresent([UserModel].self, forKey: .participants)
        lastMessage = try container.decodeIfPresent(MessageModel.self, forKey: .lastMessage)
        createdAt = try ISO8601DateFormatter().date(from: container.decodeIfPresent(String.self, forKey: .createdAt) ?? "") ?? Date()
    }
}

extension ConversationModel: Hashable, Identifiable {}
