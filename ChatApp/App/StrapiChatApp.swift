//
//  StrapiChatApp.swift
//  StrapiChat
//
//  Created by Duc on 18/8/24.
//

import ActivityIndicatorView
import SwiftUI

// MARK: - StrapiChatApp

@main
struct StrapiChatApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @ObservedObject var router = {
        let router = Router()
        ServiceLocator[Router.self] = router
        return router
    }()

    @ObservedObject var userSettings = {
        let userSettings = UserSettings()
        ServiceLocator[UserSettings.self] = userSettings
        return userSettings
    }()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                LoadingView {}
                    .onAppear {
                        if userSettings.isLoggedIn {
                            let _ = AppSocketManager.default.connect()
                            router.pop(to: .conversations)
                        } else {
                            router.pop(to: .login)
                        }
                    }
                    .navigationDestination(for: Route.self) {
                        switch $0 {
                        case .login:
                            LoginScene()
                        case .friends:
                            FriendsScene()
                        case .conversations:
                            ConversationsScene()
                                .configure()
                        case let .conversation(conversation):
                            ConversationScene()
                                .configure(conversation: conversation)
                        }
                    }
            }
            .environmentObject(router)
            .environmentObject(userSettings)
            .preferredColorScheme(.light)
        }
    }
}

// MARK: - AppDelegate

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        return true
    }
}
