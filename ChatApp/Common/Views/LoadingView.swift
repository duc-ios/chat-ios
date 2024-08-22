//
//  LoadingView.swift
//  ChatApp
//
//  Created by Duc on 22/8/24.
//

import ActivityIndicatorView
import SwiftUI

struct LoadingView<Content: View>: View {
    @Binding var isVisible: Bool
    @ViewBuilder var content: () -> Content

    init(
        isVisible: Binding<Bool> = .constant(true),
        @ViewBuilder content: @escaping () -> Content
    ) {
        _isVisible = isVisible
        self.content = content
    }

    var body: some View {
        ZStack {
            content()
            if isVisible {
                Rectangle()
                    .foregroundColor(.black.opacity(0.3))
                    .ignoresSafeArea()
                ActivityIndicatorView(isVisible: $isVisible, type: .equalizer(count: 4))
                    .frame(width: 44, height: 44)
            }
        }
    }
}

#Preview {
    LoadingView(isVisible: .constant(true), content: {
        Text("hello")
    })
}
