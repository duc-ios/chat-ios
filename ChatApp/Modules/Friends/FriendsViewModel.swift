//
//  FriendsViewModel.swift
//  StrapiChat
//
//  Created by Duc on 18/8/24.
//

import SwiftUI
import SwiftyJSON

final class FriendsViewModel: BaseViewModel {
    enum State: Hashable {
        case error(AppError)
        case conversationFound(ConversationModel)
    }

    @Published var state: State?
    let worker = ConversationWorker()
    @Published var friends = [UserModel]()
    private var activeUserIds = [Int]()

    override init() {
        super.init()
        AppSocketManager.default.on("users") { [weak self] data, _ in
            guard let self else { return }
            if let data = data.first {
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    do {
                        activeUserIds = try [UserModel](data).map { $0.id }
                        for idx in 0 ..< friends.count {
                            friends[idx].isActive = activeUserIds.contains(friends[idx].id)
                        }
                    } catch {
                        state = .error(.error(error))
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

    func findFriends() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            switch await worker.findFriends() {
            case var .success(friends):
                for idx in 0 ..< friends.count {
                    friends[idx].isActive = activeUserIds.contains(friends[idx].id)
                }
                self.friends = friends
            case let .failure(error):
                state = .error(error)
            }
        }
    }

            }
        }
    }
}
