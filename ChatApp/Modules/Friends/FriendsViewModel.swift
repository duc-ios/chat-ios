//
//  FriendsViewModel.swift
//  StrapiChat
//
//  Created by Duc on 18/8/24.
//

import ExyteChat
import SwiftUI
import SwiftyJSON

final class FriendsViewModel: BaseViewModel {
    enum State {
        case loggedOut
    }

    @Published var state: State?
    let worker = ConversationWorker()
    @Published var friends = [UserModel]()

    override init() {
        super.init()
        AppSocketManager.default.on("users") { [weak self] data, _ in
            guard let self else { return }
            if let data = data.first {
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    do {
                        let activeFriends = try [UserModel](data).map { $0.id }
                        for idx in 0..<friends.count {
                            friends[idx].isActive = activeFriends.contains(friends[idx].id)
                        }
                    } catch {
                        showError(.error(error))
                    }
                }
            }
        }

        findFriends()
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

    func findFriends() {
        Task { [weak self] in
            guard let self else { return }
            switch await worker.findFriends() {
            case .success(let friends):
                self.friends = friends
            case .failure(let error):
                showError(error)
            }
        }
    }
}
