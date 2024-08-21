//
//  StrapiChatApp.swift
//  StrapiChat
//
//  Created by Duc on 18/8/24.
//

import ExyteChat
import SwiftUI

@main
struct StrapiChatApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @ObservedObject var router = Router()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                ProgressView()
                    .scaleEffect(.init(width: 2, height: 2))
                    .onAppear {
                        if UserSettings.isLoggedIn {
                            AppSocketManager.default.connect()
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
                        case .conversation(let conversation):
                            ConversationScene()
                                .configure(conversation: conversation)
                        }
                    }
            }
            .environmentObject(router)
            .preferredColorScheme(.light)
        }
    }
}

extension UINavigationController {
    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        // hide back button text
        navigationBar.topItem?.backButtonDisplayMode = .minimal
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        return true
    }
}
