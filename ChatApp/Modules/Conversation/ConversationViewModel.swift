//
//  ConversationViewModel.swift
//  StrapiChat
//
//  Created by Duc on 18/8/24.
//

import SwiftUI
import SwiftyJSON

class ConversationViewModel: BaseViewModel {
    let worker = ConversationWorker()

    @Published var messages: [MessageModel] = []

    var recipent: UserModel!
    var conversation: ConversationModel!

    @MainActor
    func configure(conversation: ConversationModel) {
        self.conversation = conversation

        AppSocketManager.default.on("message:create", onMessageCreate)
        AppSocketManager.default.on("message:update", onMessageUpdate)

        findMessages()
    }

    deinit {
        AppSocketManager.default.off("message:create")
        AppSocketManager.default.off("message:update")
    }

    @MainActor
    func findMessages() {
        Task { [weak self] in
            guard let self else { return }
            do {
                let messages = try await worker.findMessages(refId: conversation.refId)
                self.messages += messages
            } catch {
                showError(.error(error))
            }
        }
    }

    func send(id: String? = nil, text: String) {
        Task { [weak self] in
            guard let self else { return }
            do {
                if let id {
                    try await worker.update(id: id, text: text)
                } else {
                    try await worker.create(text: text, to: conversation.refId)
                }
            } catch {
                showError(.error(error))
            }
        }
    }

    func onMessageCreate(data: [Any], emitter _: Any) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                var messages = [MessageModel]()
                for messageData in data {
                    let json = JSON(messageData)
                    let message = try await worker.buildMessage(json: json)
                    messages.append(message)
                }
                self.messages += messages
            } catch {
                showError(.error(error))
            }
        }
    }

    func onMessageUpdate(data: [Any], emitter _: Any) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                for messageData in data {
                    let json = JSON(messageData)
                    var message = try await worker.buildMessage(json: json)
                    message.triggerRedraw = UUID()
                    if let idx = messages.firstIndex(where: { $0.id == message.id }) {
                        self.messages[idx] = message
                    } else {
                        messages.append(message)
                    }
                }
            } catch {
                showError(.error(error))
            }
        }
    }
}
