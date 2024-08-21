//
//  ConversationWorker.swift
//  StrapiChat
//
//  Created by Duc on 18/8/24.
//

import ExyteChat
import Foundation
import SwiftyJSON

class ConversationWorker: APIWorker {
    private var users = [Int: UserModel]()

    func login(identifier: String, password: String) async -> Result<UserModel, AppError> {
        do {
            let json = try await request(
                method: "POST",
                path: "api/auth/local",
                body: [
                    "identifier": identifier,
                    "password": password
                ])
            var user = try UserModel(json["user"].rawValue)
            user.jwt = json["jwt"].stringValue
            UserSettings.me = user
            return .success(user)
        } catch {
            UserSettings.me = nil
            return .failure(.error(error))
        }
    }

    func findConversation(recipentId: Int?) async -> Result<ConversationModel, AppError> {
        do {
            let json = try await request(
                method: "GET",
                path: "api/conversations",
                queries: [
                    "filters[recipentId]": recipentId?.stringValue
                ])

            let data = json["data"]
            if data.isEmpty {
                return .failure(.message("404 Not Found"))
            } else {
                return try .success(ConversationModel(data[0].rawValue))
            }
        } catch {
            return .failure(.error(error))
        }
    }

    func findMessages(refId: String) async throws -> [Message] {
        let json = try await request(method: "GET", path: "api/messages", queries: [
            "populate": "sender",
            "filters[conversation][refId]": refId,
            "sort": "createdAt:desc"
        ])
        let result = json["data"].arrayValue
        var messages = [Message]()
        for messageJson in result {
            let message = try await buildMessage(json: messageJson)
            messages.append(message)
        }
        return messages.reversed()
    }

    @discardableResult
    func send(text: String, to conversationRefId: String) async throws -> String {
        let json = try await request(
            method: "POST",
            path: "api/messages",
            queries: ["populate": "*"],
            body: [
                "data": [
                    "content": text,
                    "conversation": conversationRefId
                ]
            ])
        return json["data"]["id"].stringValue
    }

    func buildMessage(json: JSON) async throws -> Message {
        let senderId = json["sender"]["id"].intValue
        let user = try await findUser(id: senderId == 0 ? UserSettings.me!.id : senderId)
        let message = Message(
            id: json["id"].stringValue,
            user: user.toUser(),
            createdAt: ISO8601DateFormatter().date(from: json["createdAt"].stringValue) ?? Date(),
            text: json["content"].stringValue)
        return message
    }

    func findUser(id: Int) async throws -> UserModel {
        if let user = users[id] { return user }

        let json = try await request(
            method: "GET",
            path: "api/users/\(id)",
            queries: ["populate": "avatar"])
        let user = try UserModel(json)
        users[id] = user
        return user
    }

    func findFriends() async -> Result<[UserModel], AppError> {
        do {
            let json = try await request(
                method: "GET",
                path: "api/users",
                queries: [
                    "populate": "avatar",
                    "filters[id][$ne]": UserSettings.me?.id.stringValue
                ])
            let friends = try json.arrayValue.map {
                let user = try UserModel($0)
                users[user.id] = user
                return user
            }
            return .success(friends)
        } catch {
            return .failure(.error(error))
        }
    }

    func findConversations() async -> Result<[ConversationModel], AppError> {
        do {
            let json = try await request(
                method: "GET",
                path: "api/conversations")
            return try .success([ConversationModel](json["data"].rawValue))
        } catch {
            return .failure(.error(error))
        }
    }
}
