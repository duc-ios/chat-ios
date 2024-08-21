//
//  ConversationModel.swift
//  StrapiChat
//
//  Created by Duc on 19/8/24.
//

import Foundation

class ConversationModel: Codable, Hashable, Identifiable {
    static func == (lhs: ConversationModel, rhs: ConversationModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(refId)
        hasher.combine(participants)
        hasher.combine(lastMessage)
    }

    var id: Int
    var name: String?
    var refId: String
    var participants: [UserModel]?
    var lastMessage: MessageModel?
}
