//
//  ConversationSceneModel.swift
//  StrapiChat
//
//  Created by Duc on 18/8/24.
//

import ExyteChat
import SwiftUI
import SwiftyJSON

class ConversationSceneModel: ObservableObject {
    @Published var showError = false
    @Published var error: AppError?
    
    let worker = ConversationWorker()

    @Published var messages: [Message] = []
        
    var recipent: UserModel!
    var conversation: ConversationModel!
    
    func showError(_ error: AppError) {
        Task { @MainActor in
            self.error = error
            showError = true
        }
    }
    
    @MainActor
    func configure(recipent: UserModel) {
        self.recipent = recipent
        
        AppSocketManager.default.on("message:create") { [weak self] data, _ in
            self?.onMessageCreate(data: data)
        }
    }
    
    deinit {
        AppSocketManager.default.off("message:create")
    }
    
    @MainActor
    func findConversation() {
        Task { [weak self] in
            guard let self else { return }
            switch await worker.findConversation(recipentId: recipent.id) {
            case .success(let conversation):
                self.conversation = conversation
                findMessages()
            case .failure(let error):
                showError(error)
            }
        }
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
