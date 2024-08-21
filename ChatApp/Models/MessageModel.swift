//
//  MessageModel.swift
//  ChatApp
//
//  Created by Duc on 21/8/24.
//

import Foundation

struct MessageModel: Codable, Hashable, Identifiable {
    let id: Int
    let content: String
    let sender: UserModel?
    let conversation: ConversationModel?
}
