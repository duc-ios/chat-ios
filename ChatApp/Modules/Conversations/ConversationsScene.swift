//
//  ConversationsScene.swift
//  ChatApp
//
//  Created by Duc on 22/8/24.
//

import SwiftUI

extension ConversationsScene {
    func configure() -> Self {
        return self
    }
}

struct ConversationsScene: View {
    @ObservedObject var viewModel = ConversationsViewModel()
    @EnvironmentObject var router: Router

    var body: some View {
        Group {
            if viewModel.conversations.isEmpty {
                Text("No conversations found")
            } else {
                List {
                    ForEach(viewModel.conversations) { conversation in
                        let sender = conversation.participants?.first(where: { $0.id != UserSettings.me?.id })
                        return NavigationLink(value: Route.conversation(conversation)) {
                            HStack {
                                ZStack(alignment: .topTrailing) {
                                    CircleAvatar(url: sender?.avatar)
                                    ZStack {
                                        Circle().fill(.green)
                                        Circle().strokeBorder(.white, lineWidth: 2)
                                    }
                                    .frame(width: 12, height: 12)
                                }
                                VStack(alignment: .leading) {
                                    Text(conversation.name ?? sender?.username ?? "").fontWeight(.semibold)
                                    if let lastMessage = conversation.lastMessage?.content {
                                        Text(lastMessage)
                                            .lineLimit(2)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .alert(
            isPresented: self.$viewModel.showError,
            error: viewModel.error,
            actions: { _ in
                Button("OK") {}
            },
            message: { Text($0.message) }
        )
        .navigationBarBackButtonHidden()
        .navigationTitle("Welcome, \(UserSettings.me?.username ?? "")")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Friends") {
                    router.show(.friends)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Logout") {
                    viewModel.logout()
                }
            }
        }
        .onChange(of: viewModel.state) {
            switch $0 {
            case .loggedOut:
                self.router.pop(to: .login)
            default:
                break
            }
        }
    }
}

#if DEBUG
#Preview {
    ConversationsScene()
        .configure()
}
#endif
