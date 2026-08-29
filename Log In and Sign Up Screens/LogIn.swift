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
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    HLogoView()
                        .frame(height: 120)

                    Text("Welcome back")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(Color.charcoal)

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
                        prompt: "college@email.com",
                        systemImage: "envelope.fill",
                        validationMessage: viewModel.isValidEmail || viewModel.emailText.isEmpty ? nil : "Enter a valid email address."
                    )

                    AuthSecureField(
                        title: "Password",
                        text: Binding(
                            get: { viewModel.passwordText },
                            set: { viewModel.updatePassword($0) }
                        ),
                        prompt: "Password",
                        validationMessage: viewModel.isValidPassword || viewModel.passwordText.isEmpty ? nil : "Use 8+ characters with 1 uppercase, 1 number, and 1 symbol."
                    )

                    Button("Forgot your password?") {
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.charcoal.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .trailing)

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.red)
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
                        .background(Color.mediumMint, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.isLoading)
                    .opacity(viewModel.isLoading ? 0.7 : 1)

                    Button {
                        viewModel.fillDemoCredentials()
                    } label: {
                        Text("Use Demo Account")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.charcoal)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.lightMint.opacity(0.55), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        RegistrationView()
                    } label: {
                        Text("Create New Account")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(Color.charcoal)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.white, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .stroke(Color.mediumMint.opacity(0.35), lineWidth: 1.5)
                            )
                    }
                }
                .padding(24)
                .background(Color.white.opacity(0.96), in: RoundedRectangle(cornerRadius: 34, style: .continuous))
                .shadow(color: Color.charcoal.opacity(0.08), radius: 20, y: 12)

                VStack(spacing: 8) {
                    Text("Demo login")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.charcoal)
                    Text("Email: test@example.com")
                        .font(.caption)
                        .foregroundStyle(Color.charcoal.opacity(0.6))
                    Text("Password: Password1!")
                        .font(.caption)
                        .foregroundStyle(Color.charcoal.opacity(0.6))
                }
                .padding(.bottom, 28)
            }
            .padding(.horizontal, 22)
        }
        .background(BackgroundA())
        .navigationBarTitleDisplayMode(.inline)
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
                    .foregroundStyle(Color.mediumMint)

                TextField(prompt, text: $text)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .foregroundStyle(Color.charcoal)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
            .background(Color.lightMint.opacity(0.45), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(validationMessage == nil ? Color.mediumMint.opacity(0.2) : .red.opacity(0.45), lineWidth: 1.5)
            )

            if let validationMessage {
                Text(validationMessage)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.red)
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

            HStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .foregroundStyle(Color.mediumMint)

                Group {
                    if isShowingText {
                        TextField(prompt, text: $text)
                    } else {
                        SecureField(prompt, text: $text)
                    }
                }
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .foregroundStyle(Color.charcoal)

                Button {
                    isShowingText.toggle()
                } label: {
                    Image(systemName: isShowingText ? "eye.slash.fill" : "eye.fill")
                        .foregroundStyle(Color.charcoal.opacity(0.55))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
            .background(Color.lightMint.opacity(0.45), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(validationMessage == nil ? Color.mediumMint.opacity(0.2) : .red.opacity(0.45), lineWidth: 1.5)
            )

            if let validationMessage {
                Text(validationMessage)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.red)
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

protocol AuthServicing {
    func signIn(email: String, password: String) async throws -> UserProfile
    func signUp(firstName: String, lastName: String, email: String, password: String) async throws -> UserProfile
}

enum AuthError: LocalizedError {
    case invalidCredentials
    case emailAlreadyInUse
    case network
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password."
        case .emailAlreadyInUse:
            return "That email already has an account."
        case .network:
            return "Network error. Please try again."
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
}

struct AuthService: AuthServicing {
    nonisolated init() {}

    nonisolated func signIn(email: String, password: String) async throws -> UserProfile {
        try await Task.sleep(nanoseconds: 800_000_000)

        guard email.lowercased() == "test@example.com", password == "Password1!" else {
            throw AuthError.invalidCredentials
        }

        return UserProfile(
            firstName: "Lyla",
            lastName: "Goldman",
            email: email.lowercased(),
            preferredCurrency: "$",
            joinedDate: .now
        )
    }

    nonisolated func signUp(firstName: String, lastName: String, email: String, password: String) async throws -> UserProfile {
        try await Task.sleep(nanoseconds: 800_000_000)

        if email.lowercased() == "test@example.com" {
            throw AuthError.emailAlreadyInUse
        }

        return UserProfile(
            firstName: firstName,
            lastName: lastName,
            email: email.lowercased(),
            preferredCurrency: "$",
            joinedDate: .now
        )
    }
}

@MainActor
final class LogInViewModel: ObservableObject {
    @Published var emailText = ""
    @Published var passwordText = ""
    @Published var isValidEmail = true
    @Published var isValidPassword = true
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let auth: AuthServicing

    init(auth: AuthServicing = AuthService()) {
        self.auth = auth
    }

    var canProceed: Bool {
        Validator.validateEmail(emailText) && Validator.validatePassword(passwordText) && !isLoading
    }

    func updateEmail(_ newValue: String) {
        emailText = newValue
        isValidEmail = Validator.validateEmail(newValue)
    }

    func updatePassword(_ newValue: String) {
        passwordText = newValue
        isValidPassword = Validator.validatePassword(newValue)
    }

    func signIn(onSuccess: @escaping (UserProfile) -> Void) {
        errorMessage = nil
        guard Validator.validateEmail(emailText) else {
            errorMessage = "Enter a valid email address."
            return
        }

        guard Validator.validatePassword(passwordText) else {
            errorMessage = "Use the demo password or a password with 8+ characters, 1 uppercase, 1 number, and 1 symbol."
            return
        }
        isLoading = true

        Task {
            do {
                let user = try await auth.signIn(email: emailText, password: passwordText)
                isLoading = false
                onSuccess(user)
            } catch {
                isLoading = false
                if let authError = error as? AuthError {
                    errorMessage = authError.localizedDescription
                } else {
                    errorMessage = AuthError.unknown.localizedDescription
                }
            }
        }
    }

    func fillDemoCredentials() {
        updateEmail("test@example.com")
        updatePassword("Password1!")
        errorMessage = nil
    }
}
