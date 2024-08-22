//
//  FriendsScene.swift
//  StrapiChat
//
//  Created by Duc on 18/8/24.
//

import Kingfisher
import SwiftUI

struct FriendsScene: View {
    @ObservedObject var viewModel = FriendsViewModel()
    @EnvironmentObject var router: Router

    var body: some View {
        Group {
            if viewModel.friends.isEmpty {
                Text("No friends online")
            } else {
                List {
                    ForEach(viewModel.friends) { friend in
                        HStack {
                            ZStack(alignment: .topTrailing) {
                                CircleAvatar(url: friend.avatar)
                                if friend.isActive {
                                    ZStack {
                                        Circle().fill(.green)
                                        Circle().strokeBorder(.white, lineWidth: 2)
                                    }
                                    .frame(width: 12, height: 12)
                                }
                            }
                            Text(friend.username)
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
        .navigationTitle("Friends")
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

#Preview {
    FriendsScene()
        .environmentObject(Router())
}

extension Shape {
    func fill<Fill: ShapeStyle, Stroke: ShapeStyle>(_ fillStyle: Fill, strokeBorder strokeStyle: Stroke, lineWidth: Double = 1) -> some View {
        stroke(strokeStyle, lineWidth: lineWidth)
            .background(fill(fillStyle))
    }
}
