//
//  ConversationScene.swift
//  StrapiChat
//
//  Created by Duc on 18/8/24.
//

import ExyteChat
import os
import SocketIO
import SwiftUI
import SwiftyJSON

enum ConversationAction: MessageMenuAction {
    case reply, edit

    func title() -> String {
        switch self {
        case .reply:
            "Reply"
        case .edit:
            "Edit"
        }
    }

    func icon() -> Image {
        switch self {
        case .reply:
            Image(systemName: "arrowshape.turn.up.left")
        case .edit:
            Image(systemName: "square.and.pencil")
        }
    }
}

struct ConversationScene: View {
    @ObservedObject var viewModel = ConversationSceneModel()

    var body: some View {
        ChatView(messages: viewModel.messages, didSendMessage: {
            viewModel.send(draft: $0)
        }).setAvailableInput(.textOnly)

//        , inputViewBuilder: { text, _, inputViewState, inputViewStyle, inputViewActionClosure, _ in
//            Group {
//                switch inputViewStyle {
//                case .message: // input view on chat screen
//                    HStack {
//                        Button(action: { inputViewActionClosure(.photo) },
//                               label: { Image(systemName: "paperclip") })
//                            .foregroundStyle(.gray)
//                        TextField("Write your message", text: text)
//                            .onSubmit { inputViewActionClosure(.send) }
//                        Button(action: { inputViewActionClosure(.send) },
//                               label: { Image(systemName: "paperplane") })
//                            .disabled(inputViewState != .hasTextOrMedia)
//                    }
//                    .padding()
//                    .background(Capsule().fill(Color(hex: "EBEDF0")))
//                    .padding()
//                case .signature: // input view on photo selection screen
//                    HStack {
//                        Button(action: { inputViewActionClosure(.send) },
//                               label: { Image(systemName: "paperplane") })
//                        TextField("Compose a signature for photo", text: text)
//                            .background(Color.green)
//                    }
//                    .padding()
//                    .background(Capsule().fill(Color(hex: "EBEDF0")))
//                    .padding()
//                }
//            }
//        }, messageMenuAction: { (action: ConversationAction, defaultActionClosure, message) in
//            switch action {
//            case .reply:
//                defaultActionClosure(message, .reply)
//            case .edit:
//                defaultActionClosure(message, .edit { editedText in
//                    // update this message's text on your BE
//                    logger.debug(editedText)
//                })
//            }
//        })

            .alert(
                isPresented: $viewModel.showError,
                error: viewModel.error,
                actions: { _ in
                    Button("OK") {}
                },
                message: { Text($0.message) }
            )
            .onAppear {
                viewModel.findConversation()
            }
            .navigationTitle(viewModel.conversation?.name ?? "")
            .navigationBarTitleDisplayMode(.inline)
    }
}

extension ConversationScene {
    func configure(recipent: UserModel) -> Self {
        viewModel.configure(recipent: recipent)
        return self
    }
}

#Preview {
    ConversationScene().configure(recipent: try! UserModel([
        "id": 1,
        "socketId": "",
        "username": "duc",
        "avatar": [
            "large": [
                "url": "/uploads/large_pexels_ali_pazani_4407688_0f1f37b58d.jpeg"
            ],
            "medium": [
                "url": "/uploads/medium_pexels_ali_pazani_4407688_0f1f37b58d.jpeg"
            ],
            "small": [
                "url": "/uploads/small_pexels_ali_pazani_4407688_0f1f37b58d.jpeg"
            ],
            "thumbnail": [
                "url": "/uploads/thumbnail_pexels_ali_pazani_4407688_0f1f37b58d.jpeg"
            ]
        ]
    ]))
    .environmentObject(Router())
}
