//
//  LoginViewModel.swift
//  StrapiChat
//
//  Created by Duc on 19/8/24.
//

import Foundation

final class LoginViewModel: BaseViewModel {
    enum State: Hashable {
        case error(AppError)
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
                state = .error(error)
            }
            isLoading = false
        }
    }
}
