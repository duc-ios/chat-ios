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
                    .onAppear {
                        if UserSettings.isLoggedIn {
                            AppSocketManager.default.connect()
                            router.pop(to: .friends)
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
                        case .conversation(let user):
                            ConversationScene()
                                .configure(recipent: user)
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
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool
    {
        return true
    }
}
