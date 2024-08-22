//
//  LoginViewModel.swift
//  StrapiChat
//
//  Created by Duc on 19/8/24.
//

import Foundation

final class LoginViewModel: BaseViewModel {
    enum State {
        case loggedIn
    }

    @Published var state: State?

    let worker = ConversationWorker()

    @MainActor
    func login(identifier: String, password: String) {
        Task { [weak self] in
            guard let self else { return }
            isLoading = true
            try await Task.sleep(for: Duration(secondsComponent: 2, attosecondsComponent: 0))
            switch await worker.login(identifier: identifier, password: password) {
            case .success:
                state = .loggedIn
            case let .failure(error):
                showError(error)
            }
            isLoading = false
        }
    }
}
