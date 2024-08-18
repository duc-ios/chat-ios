//
//  LoginSceneModel.swift
//  StrapiChat
//
//  Created by Duc on 19/8/24.
//

import Foundation

class LoginSceneModel: ObservableObject {
    enum State {
        case loggedIn
    }

    @Published var state: State?
    @Published var error: AppError?
    @Published var showError = false

    let worker = ConversationWorker()

    func showError(_ error: AppError) {
        Task { @MainActor in
            self.error = error
            showError = true
        }
    }

    func login(identifier: String, password: String) {
        Task { [weak self] in
            guard let self else { return }
            switch await worker.login(identifier: identifier, password: password) {
            case .success:
                state = .loggedIn
            case .failure(let error):
                showError(error)
            }
        }
    }
}
