//
//  FriendsScene.swift
//  StrapiChat
//
//  Created by Duc on 18/8/24.
//

import Kingfisher
import SwiftUI

struct FriendsScene: View {
    @ObservedObject var viewModel = FriendsSceneModel()
    @EnvironmentObject var router: Router

    var body: some View {
        Group {
            if viewModel.friends.isEmpty {
                Text("No friends online")
            } else {
                List {
                    ForEach(viewModel.friends) { user in
                        NavigationLink(value: Route.conversation(user)) {
                            HStack {
                                CircleAvatar(url: user.avatar)
                                Text(user.username)
                            }
                        }
                    }
                }
            }
        }
        .alert(
            isPresented: $viewModel.showError,
            error: viewModel.error,
            actions: { _ in
                Button("OK") {}
            },
            message: { Text($0.message) }
        )
//        .onAppear {
//            viewModel.findFriends()
//        }
        .navigationBarBackButtonHidden()
        .navigationTitle("Friends")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Logout") {
                    viewModel.logout()
                }
            }
        }
        .onChange(of: viewModel.state) {
            switch $0 {
            case .loggedOut:
                router.pop(to: .login)
            default:
                break
            }
        }
    }
}

#Preview {
    FriendsScene()
        .environmentObject(Router())
}
