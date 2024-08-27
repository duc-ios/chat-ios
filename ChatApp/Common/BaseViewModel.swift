//
//  BaseViewModel.swift
//  ChatApp
//
//  Created by Duc on 22/8/24.
//

import Foundation

class BaseViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var showError = false
}
