//
//  ConversationWorker.swift
//  StrapiChat
//
//  Created by Duc on 18/8/24.
//

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
                    "password": password,
                ]
            )
            var user = try UserModel(json["user"].rawValue)
            user.jwt = json["jwt"].stringValue
            ServiceLocator[UserSettings.self]?.me = user
            return .success(user)
        } catch {
            ServiceLocator[UserSettings.self]?.me = nil
            return .failure(.error(error))
        }
    }

    func findConversation(recipentId: Int?) async -> Result<ConversationModel, AppError> {
        do {
            let json = try await request(
                method: "GET",
                path: "api/conversations",
                queries: [
                    "filters[recipentId]": recipentId?.stringValue,
                ]
            )

            let data = json["data"]
            if data.isEmpty {
                return .failure(.message(code: 404, message: "Not Found"))
            } else {
                return try .success(ConversationModel(data[0].rawValue))
            }
        } catch {
            return .failure(.error(error))
        }
    }

    func findMessages(refId: String) async throws -> [MessageModel] {
        let json = try await request(method: "GET", path: "api/messages", queries: [
            "populate": "sender",
            "filters[conversation][refId]": refId,
            "sort": "createdAt:desc",
        ])
        let result = json["data"].arrayValue
        var messages = [MessageModel]()
        for messageJson in result {
            let message = try await buildMessage(json: messageJson)
            messages.append(message)
        }
        return messages.reversed()
    }

    @discardableResult
    func create(text: String, to conversationRefId: String) async throws -> String {
        let json = try await request(
            method: "POST",
            path: "api/messages",
            queries: ["populate": "*"],
            body: [
                "data": [
                    "content": text,
                    "conversation": conversationRefId,
                ],
            ]
        )
        return json["data"]["id"].stringValue
    }

    @discardableResult
    func update(id: String, text: String) async throws -> String {
        let json = try await request(
            method: "PUT",
            path: "api/messages/\(id)",
            body: [
                "data": [
                    "content": text,
                ],
            ]
        )
        return json["data"]["id"].stringValue
    }

    func buildMessage(json: JSON) async throws -> MessageModel {
        guard let me = ServiceLocator[UserSettings.self]?.me
        else { throw AppError.unauthorized }

        let senderId = json["sender"]["id"].intValue
        let user = try await findUser(id: senderId == 0 ? me.id : senderId)
        let message = try MessageModel(json.rawValue)
        return message
    }

    func findUser(id: Int) async throws -> UserModel {
        if let user = users[id] { return user }

        let json = try await request(
            method: "GET",
            path: "api/users/\(id)",
            queries: ["populate": "avatar"]
        )
        let user = try UserModel(json)
        users[id] = user
        return user
    }

    func findFriends() async -> Result<[UserModel], AppError> {
        do {
            guard let me = ServiceLocator[UserSettings.self]?.me
            else { throw AppError.unauthorized }

            let json = try await request(
                method: "GET",
                path: "api/users",
                queries: [
                    "populate": "avatar",
                    "filters[id][$ne]": me.id.stringValue,
                ]
            )
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
                path: "api/conversations"
            )
            return try .success([ConversationModel](json["data"].rawValue))
        } catch {
            return .failure(.error(error))
        }
    }
}
