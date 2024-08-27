//
//  ConversationsViewModel.swift
//  ChatApp
//
//  Created by Duc on 22/8/24.
//

import Foundation

final class ConversationsViewModel: BaseViewModel {
    enum State: Hashable {
        case error(AppError)
        case loggedOut
    }

    @Published var state: State?
    let worker = ConversationWorker()
    @Published var conversations = [ConversationModel]()

    override init() {
        super.init()

        AppSocketManager.default.on("message:create") { [weak self] data, _ in
            guard let self,
                  let data = data.first else { return }
            do {
                let message = try MessageModel(data)
                for convoIdx in 0 ..< conversations.count {
                    let convo = conversations[convoIdx]
                    if convo.id == message.conversation?.id {
                        convo.lastMessage = message
                    }
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.conversations = conversations
                    }
                }
            } catch {
                logger.error(error)
            }
        }

        AppSocketManager.default.on("message:update") { [weak self] data, _ in
            guard let self,
                  let data = data.first else { return }
            do {
                let message = try MessageModel(data)
                conversations.first(where: { $0.lastMessage?.id == message.id })?.lastMessage = message
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.conversations = conversations
                }
            } catch {
                logger.error(error)
            }
        }

        findConversations()
    }

    deinit {
        AppSocketManager.default.off("users")
        AppSocketManager.default.off("message:update")
    }

    @MainActor
    func logout() {
        ServiceLocator[UserSettings.self]?.logout()
        state = .loggedOut
    }

    func findConversations() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            switch await worker.findConversations() {
            case let .success(conversations):
                self.conversations = conversations
            case let .failure(error):
                state = .error(error)
            }
        }
    }

            }
        }
    }
}
