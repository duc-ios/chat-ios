//
//  ConversationSceneModel.swift
//  StrapiChat
//
//  Created by Duc on 18/8/24.
//

import ExyteChat
import SwiftUI
import SwiftyJSON

class ConversationViewModel: BaseViewModel {
    let worker = ConversationWorker()

    @Published var messages: [Message] = []

    var recipent: UserModel!
    var conversation: ConversationModel!

    @MainActor
    func configure(conversation: ConversationModel) {
        self.conversation = conversation

        AppSocketManager.default.on("message:create") { [weak self] data, _ in
            self?.onMessageCreate(data: data)
        }

        findMessages()
    }

    deinit {
        AppSocketManager.default.off("message:create")
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

    func send(draft: DraftMessage) {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await worker.send(text: draft.text, to: conversation.refId)
            } catch {
                logger.error(error)
            }
        }
    }

    func onMessageCreate(data: [Any]) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                var messages = [Message]()
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
}
