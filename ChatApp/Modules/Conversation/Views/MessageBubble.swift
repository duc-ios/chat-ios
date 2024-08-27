//
//  MessageBubble.swift
//  ChatApp
//
//  Created by Duc on 22/8/24.
//

import SwiftUI

// MARK: - MessageBubble

struct MessageBubble: View {
    let message: MessageModel
    var isMine: Bool

    var body: some View {
        let forgroundColor: Color = isMine ? .blue : .gray.opacity(0.5)
        VStack {
            HStack {
                if isMine { Spacer() }
                    VStack(alignment: isMine ? .trailing : .leading) {
                        Text(message.content)
                            .foregroundStyle(isMine ? .white : .black)
                        
                        Text(message.createdAt.formatted(.relative(presentation: .named)))
                            .font(.callout)
                            .foregroundStyle((isMine ? Color.white : .gray).opacity(0.5))
                    }
                    .padding(8)
                    .background(ChatBubbleShape(direction: isMine ? .trailing : .leading))
                    .foregroundColor(forgroundColor)
                if !isMine { CircleAvatar(url: message.sender?.avatar) }
            }
        }
        .listRowSeparator(.hidden)
    }
}

// MARK: - ChatBubbleShape

struct ChatBubbleShape: Shape {
    enum Direction {
        case leading
        case trailing
    }

    let direction: Direction
    var radius: CGFloat = 16

    func path(in rect: CGRect) -> Path {
        Path { path in
            if direction == .leading {
                // arrow left
                path.move(to: CGPoint(x: rect.minX + radius, y: rect.maxY - radius))
                path.addCurve(
                    to: CGPoint(x: rect.minX, y: rect.maxY - 2 * radius),
                    control1: CGPoint(x: rect.minX - 2 * radius, y: rect.maxY + radius),
                    control2: CGPoint(x: rect.minX, y: rect.maxY)
                )
            }
            // top left
            path.addArc(
                center: CGPoint(x: rect.minX + radius, y: rect.minY + radius),
                radius: radius,
                startAngle: Angle(degrees: 180),
                endAngle: Angle(degrees: 270),
                clockwise: false
            )
            // top right
            path.addArc(
                center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius),
                radius: radius,
                startAngle: Angle(degrees: 270),
                endAngle: Angle(degrees: 0),
                clockwise: false
            )
            if direction == .trailing {
                // arrow right
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 2 * radius))
                path.addCurve(
                    to: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius),
                    control1: CGPoint(x: rect.maxX + radius, y: rect.maxY + radius),
                    control2: CGPoint(x: rect.maxX + radius, y: rect.maxY)
                )
            }
            // bottom right
            path.addArc(
                center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius),
                radius: radius,
                startAngle: Angle(degrees: 0),
                endAngle: Angle(degrees: 90),
                clockwise: false
            )
            // bottom left
            path.addArc(
                center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius),
                radius: radius,
                startAngle: Angle(degrees: 90),
                endAngle: Angle(degrees: 180),
                clockwise: false
            )
        }
    }
}

#Preview {
    List {
        MessageBubble(
            message: MessageModel(
                id: 0,
                content: "short text short text",
                sender: UserModel(
                    id: 0,
                    username: "duc",
                    avatar: URL(string: "https://i.pravatar.cc/150?img=67")
                ),
                conversation: nil,
                createdAt: Date()
            ), isMine: true
        )
        MessageBubble(
            message: MessageModel(
                id: 0,
                content: "short text short text",
                sender: UserModel(
                    id: 0,
                    username: "duc",
                    avatar: URL(string: "https://i.pravatar.cc/150?img=67")
                ),
                conversation: nil,
                createdAt: Date()
            ), isMine: false
        )
        MessageBubble(
            message: MessageModel(
                id: 0,
                content: "long text long text long text long text long text long text long text long text long text long text long text long text long text long text long text",
                sender: UserModel(
                    id: 1,
                    username: "duc",
                    avatar: URL(string: "https://i.pravatar.cc/150?img=67")
                ),
                conversation: nil,
                createdAt: Date()
            ), isMine: true
        )
        MessageBubble(
            message: MessageModel(
                id: 0,
                content: "long text long text long text long text long text long text long text long text long text long text long text long text long text long text long text",
                sender: UserModel(
                    id: 1,
                    username: "duc",
                    avatar: URL(string: "https://i.pravatar.cc/150?img=67")
                ),
                conversation: nil,
                createdAt: Date()
            ), isMine: false
        )
    }
    .listStyle(.plain)
}
