//
//  LoginScene.swift
//  StrapiChat
//
//  Created by Duc on 18/8/24.
//

import SwiftUI

struct LoginScene: View {
    @EnvironmentObject var router: Router

    @ObservedObject var viewModel = LoginViewModel()

    @State var showError = false
    @State var error: AppError?
    @State var identifier = ""
    @State var password = ""

    var body: some View {
        LoadingView(isVisible: $viewModel.isLoading) {
            content
        }
    }

    @ViewBuilder var content: some View {
        VStack(alignment: .center) {
            VStack {
                Spacer().frame(height: 32)
                Text("ChatApp")
                    .font(.largeTitle.weight(.bold))
                Spacer().frame(height: 32)

                VStack(alignment: .leading) {
                    Text("Email / Username").font(.callout)
                    TextField("Email / Username", text: $identifier)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }
                Divider()
                Spacer().frame(height: 16)
                VStack(alignment: .leading) {
                    Text("Password").font(.callout)
                    SecureField("Password", text: $password)
                }
                Divider()
                Spacer().frame(height: 16)
                Button("Login") {
                    viewModel.login(identifier: identifier, password: password)
                }.disabled(identifier.isBlank || password.isBlank)
            }
            .padding()
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 64)
        }
        .frame(maxHeight: .infinity)
        .background(Color.separator)
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
            case .loggedIn:
                router.pop(to: .conversations)
            default:
                break
            }
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    LoginScene()
        .environmentObject(Router())
}
