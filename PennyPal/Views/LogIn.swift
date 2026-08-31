//
//  LogIn.swift
//  PennyPal
//
//  Created by Lyla on 12/31/25.
//

import SwiftUI
import Combine

struct LogIn: View {
    @EnvironmentObject private var appSession: AppSession
    @StateObject private var viewModel = LogInViewModel()

    var body: some View {
        VStack(spacing: 24) {
            VStack() {
                Image("HLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal, 24)

                Text("Welcome back!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.charcoal)
                    .padding(.bottom, 8)

                Text("Sign in to keep tabs on spending, budgets, and the little wins in between.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.charcoal.opacity(0.65))
                    .padding(.horizontal, 12)
            }
            .padding(.top, 28)

            VStack(alignment: .leading, spacing: 18) {
                AuthTextField(
                    title: "Email",
                    text: Binding(
                        get: { viewModel.emailText },
                        set: { viewModel.updateEmail($0) }
                    ),
                    prompt: "name@college.edu",
                    systemImage: "envelope.fill",
                    validationMessage: viewModel.isValidEmail || viewModel.emailText.isEmpty ? nil : "Enter a valid email address."
                )
                .tint(.charcoal.opacity(0.6))

                AuthSecureField(
                    title: "Password",
                    text: Binding(
                        get: { viewModel.passwordText },
                        set: { viewModel.updatePassword($0) }
                    ),
                    prompt: "Password",
                    validationMessage: viewModel.isValidPassword || viewModel.passwordText.isEmpty ? nil : "Must be 8+ characters with 1 uppercase, 1 number, and 1 symbol."
                )
                .tint(.charcoal.opacity(0.6))


                Button("Forgot your password?") {
                    viewModel.sendPasswordReset()
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.charcoal.opacity(0.7))
                .frame(maxWidth: .infinity, alignment: .trailing)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.mutedRed)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button {
                    viewModel.signIn { user in
                        appSession.signIn(as: user)
                    }
                } label: {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(Color.charcoal)
                        }
                        Text(viewModel.isLoading ? "Signing In..." : "Sign In")
                            .font(.headline.weight(.bold))
                    }
                    .foregroundStyle(Color.charcoal)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.mediumMint, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isLoading)
                .opacity(viewModel.isLoading ? 0.7 : 1)

                NavigationLink {
                    RegistrationView()
                } label: {
                    Text("Create New Account")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.charcoal, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                }
                
                Button {
                    viewModel.fillDemoCredentials()
                    viewModel.signIn { user in
                        appSession.signIn(as: user)
                    }
                } label: {
                    Text("(Use Demo Account)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.charcoal.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .trailing)

                }
                .buttonStyle(.plain)

            }
            .padding(30)
            .background(Color.white.opacity(0.96), in: RoundedRectangle(cornerRadius: 30, style: .continuous))
            .shadow(color: Color.charcoal.opacity(0.15), radius: 50, y: 0)
        }
        .padding(.horizontal, 22)
    }
}

struct AuthTextField: View {
    let title: String
    @Binding var text: String
    let prompt: String
    let systemImage: String
    let validationMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.charcoal)

            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .foregroundStyle(Color.darkerMint.opacity(0.8))

                TextField(prompt, text: $text)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .foregroundStyle(Color.charcoal)
                    .tint(.charcoal.opacity(0.8))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
            .background(Color.lightMint.opacity(0.65), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .stroke(validationMessage == nil ? Color.darkerMint.opacity(0.3) : .mutedRed)
            )

            if let validationMessage {
                Text(validationMessage)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.mutedRed)
            }
        }
    }
}

struct AuthSecureField: View {
    let title: String
    @Binding var text: String
    let prompt: String
    let validationMessage: String?

    @State private var isShowingText = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.charcoal)
                .tint(.charcoal.opacity(0.6))


            HStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .foregroundStyle(Color.darkerMint.opacity(0.8))

                Group {
                    if isShowingText {
                        TextField(prompt, text: $text)
                            .foregroundStyle(.charcoal)
                    } else {
                        SecureField(prompt, text: $text)
                            .foregroundStyle(.charcoal)
                    }
                }
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)

                Button {
                    isShowingText.toggle()
                } label: {
                    Image(systemName: isShowingText ? "eye.slash.fill" : "eye.fill")
                        .foregroundStyle(Color.charcoal.opacity(0.75))
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(height: 20)
            

            .padding(.horizontal, 16)
            .padding(.vertical, 18)
            .background(Color.lightMint.opacity(0.65), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .stroke(validationMessage == nil ? Color.darkerMint.opacity(0.3) : .mutedRed, lineWidth: 1.5)
            )

            if let validationMessage {
                Text(validationMessage)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.mutedRed)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    NavigationStack {
        LogIn()
            .environmentObject(AppSession())
    }
}
