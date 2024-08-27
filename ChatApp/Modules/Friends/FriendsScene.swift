//
//  FriendsScene.swift
//  StrapiChat
//
//  Created by Duc on 18/8/24.
//

import Kingfisher
import SwiftUI

// MARK: - FriendsScene

struct FriendsScene: View {
    @ObservedObject var viewModel = FriendsViewModel()
    @EnvironmentObject var router: Router

    @State var error: AppError?
    @State var showError = false

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
            isPresented: $showError,
            error: error,
            actions: { _ in
                Button("OK") {}
            },
            message: { Text($0.message) }
        )
        .onChange(of: viewModel.state) {
            switch $0 {
            case let .error(error):
                self.error = error
                self.showError = true
            case let .conversationFound(conversation):
                self.router.pop(to: .conversation(conversation))
            default:
                break
            }
        }
        .navigationTitle("Friends")
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
