//
//  BaseViewModel.swift
//  ChatApp
//
//  Created by Duc on 22/8/24.
//

import Foundation

class BaseViewModel: ObservableObject {
    @Published var showError = false
    @Published var error: AppError?

    func showError(_ error: AppError) {
        Task { @MainActor in
            self.error = error
            showError = true
        }
    }
}
