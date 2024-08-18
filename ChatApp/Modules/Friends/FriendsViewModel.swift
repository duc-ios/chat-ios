//
//  FriendsSceneModel.swift
//  StrapiChat
//
//  Created by Duc on 18/8/24.
//

import ExyteChat
import SwiftUI
import SwiftyJSON

class FriendsSceneModel: ObservableObject {
    enum State {
        case loggedOut
    }
    
    @Published var state: State?
    @Published var error: AppError?
    @Published var showError = false
        
    let worker = ConversationWorker()
    @Published var friends = [UserModel]()
    
    init() {
        AppSocketManager.default.on("users") { [weak self] data, _ in
            guard let self else { return }
            if let data = data.first {
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    do {
                        friends = try [UserModel](data).filter { $0.id != UserSettings.me?.id }
                    } catch {
                        showError(.error(error))
                    }
                }
            }
        }
    }
    
    deinit {
        cleanup()
    }
    
    func cleanup() {
        AppSocketManager.default.off("users")
    }

    func showError(_ error: AppError) {
        Task { @MainActor in
            self.error = error
            showError = true
        }
    }
    
    func logout() {
        cleanup()
        UserSettings.me = nil
        state = .loggedOut
    }
}
