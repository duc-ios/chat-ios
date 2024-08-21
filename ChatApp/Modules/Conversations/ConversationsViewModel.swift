//
//  ConversationsViewModel.swift
//  ChatApp
//
//  Created by Duc on 22/8/24.
//

import Foundation

final class ConversationsViewModel: BaseViewModel {
    enum State {
        case loggedOut
    }

    @Published var state: State?
    let worker = ConversationWorker()
    @Published var conversations = [ConversationModel]()

    override init() {
        super.init()
        AppSocketManager.default.on("users") { [weak self] data, _ in
            guard let self else { return }
            if let data = data.first {
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    do {
                        let activeFriends = try [UserModel](data).map { $0.id }
                        for convoIdx in 0..<conversations.count {
                            let convo = conversations[convoIdx]
                            for participantIdx in 0..<(convo.participants?.count ?? 0) {
                                let participant = convo.participants![participantIdx]
                                conversations[convoIdx].participants?[participantIdx].isActive = activeFriends.contains(participant.id)
                            }
                        }
                    } catch {
                        showError(.error(error))
                    }
                }
            }
        }

        AppSocketManager.default.on("message:create") { [weak self] data, _ in
            guard let self,
                  let data = data.first else { return }
            do {
                let message = try MessageModel(data)
                for convoIdx in 0..<conversations.count {
                    let convo = conversations[convoIdx]
                    if convo.id == message.conversation?.id {
                        convo.lastMessage = message
                    }
                    self.conversations = conversations
                }
            } catch {
                logger.error(error)
            }
        }

        findConversations()
    }

    deinit {
        cleanup()
    }

    func cleanup() {
        AppSocketManager.default.off("users")
    }

    @MainActor
    func logout() {
        cleanup()
        UserSettings.me = nil
        state = .loggedOut
    }

    func findConversations() {
        Task { [weak self] in
            guard let self else { return }
            switch await worker.findConversations() {
            case .success(let conversations):
                self.conversations = conversations
            case .failure(let error):
                showError(error)
            }
        }
    }
}
