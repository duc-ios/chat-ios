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

// MARK: - MessageAction

enum MessageAction: MessageMenuAction {
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

// MARK: - ConversationScene

struct ConversationScene: View {
    @ObservedObject var viewModel = ConversationViewModel()

    @State var showError = false
    @State var error: AppError?

    var body: some View {
        ChatView(
            messages: viewModel.messages.compactMap { $0.toMessage() },
            didSendMessage: {
                viewModel.send(text: $0.text)
            },
            messageMenuAction: { (action: MessageAction, defaultActionClosure, message) in
                switch action {
                case .reply:
                    defaultActionClosure(message, .reply)
                case .edit:
                    defaultActionClosure(message, .edit { editedText in
                        viewModel.send(id: message.id, text: editedText)
                    })
                }
            }
        )
        .setAvailableInput(.textOnly)
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
//        })
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
            default:
                break
            }
        }
        .navigationTitle(viewModel.conversation?.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension ConversationScene {
    func configure(conversation: ConversationModel) -> Self {
        viewModel.configure(conversation: conversation)
        return self
    }
}

#Preview {
    ConversationScene().configure(conversation: ConversationModel())
        .environmentObject(Router())
}
