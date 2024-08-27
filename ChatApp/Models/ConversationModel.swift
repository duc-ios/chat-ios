//
//  ConversationModel.swift
//  StrapiChat
//
//  Created by Duc on 19/8/24.
//

import Foundation

// MARK: - ConversationModel

class ConversationModel: Codable {
    var id: Int
    var documentId: String
    var name: String?
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
            documentId,
            participants,
            lastMessage,
            createdAt).forEach { hasher.combine($0) }
    }

    init(id: Int = -1,
         documentId: String = "",
         name: String? = nil,
         participants: [UserModel]? = nil,
         lastMessage: MessageModel? = nil,
         createdAt: Date = Date())
    {
        self.id = id
        self.documentId = documentId
        self.name = name
        self.participants = participants
        self.lastMessage = lastMessage
        self.createdAt = createdAt
    }

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        documentId = try container.decode(String.self, forKey: .documentId)
        participants = try container.decodeIfPresent([UserModel].self, forKey: .participants)
        lastMessage = try container.decodeIfPresent(MessageModel.self, forKey: .lastMessage)
        createdAt = try ISO8601DateFormatter().date(from: container.decodeIfPresent(String.self, forKey: .createdAt) ?? "") ?? Date()
    }
}

// MARK: Hashable, Identifiable

extension ConversationModel: Hashable, Identifiable {}
