//
//  SignUp.swift
//  PennyPal
//
//  Created by Lyla on 10/30/25.
//

import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject private var appSession: AppSession
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var emailText = ""
    @State private var passwordText = ""
    @State private var confirmPasswordText = ""
    @State private var errorMessage: String?
    @State private var isLoading = false

    // Keep registration on the same backend as sign-in so an account created
    // here is immediately available to Firebase Authentication.
    private let authService: AuthServicing = FirebaseAuthService()

    private var isValidEmail: Bool {
        emailText.isEmpty || Validator.validateEmail(emailText)
    }

    private var isValidPassword: Bool {
        passwordText.isEmpty || Validator.validatePassword(passwordText)
    }

    private var isConfirmPasswordValid: Bool {
        confirmPasswordText.isEmpty || confirmPasswordText == passwordText
    }

    private var canProceed: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        Validator.validateEmail(emailText) &&
        Validator.validatePassword(passwordText) &&
        confirmPasswordText == passwordText &&
        !isLoading
    }

    private var usesCompactLayout: Bool {
        horizontalSizeClass == .compact
    }

    var body: some View {
        VStack(spacing: 10) {
            VStack(spacing: 5) {
                Image("HLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
                    .frame(maxWidth: .infinity, alignment: .top)
                
                Text("Create your account")
                    .font(.system(size: usesCompactLayout ? 30 : 34, weight: .bold))
                    .foregroundStyle(Color.charcoal)

                Text("Set up PennyPal so your spending, goals, and budgets can all live in one place.")
                    .font(usesCompactLayout ? .subheadline : .body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.charcoal.opacity(0.65))
                    .padding(.horizontal, 12)
            }
            .padding(.vertical, 10)
            ScrollView(showsIndicators: true) {
                VStack(alignment: .leading, spacing: 18) {
                    if usesCompactLayout {
                        VStack(spacing: 18) {
                            firstNameField
                            lastNameField
                        }
                    } else {
                        HStack(alignment: .top, spacing: 14) {
                            firstNameField
                            lastNameField
                        }
                    }

                    AuthTextField(
                        title: "Email",
                        text: $emailText,
                        prompt: "you@school.edu",
                        systemImage: "envelope.fill",
                        validationMessage: isValidEmail ? nil : "Enter a valid email address."
                    )

                    AuthSecureField(
                        title: "Password",
                        text: $passwordText,
                        prompt: "Create a password",
                        validationMessage: isValidPassword ? nil : "Use 8+ characters with 1 uppercase, 1 number, and 1 symbol."
                    )

                    AuthSecureField(
                        title: "Confirm Password",
                        text: $confirmPasswordText,
                        prompt: "Re-enter password",
                        validationMessage: isConfirmPasswordValid ? nil : "Passwords need to match."
                    )

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.red)
                    }

                    Button {
                        signUp()
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .tint(Color.charcoal)
                            }
                            Text(isLoading ? "Creating Account..." : "Sign Up")
                                .font(.headline.weight(.bold))
                        }
                        .foregroundStyle(Color.charcoal)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.mediumMint, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .disabled(isLoading)
                    .opacity(isLoading ? 0.7 : 1)

                    NavigationLink {
                        LogIn()
                    } label: {
                        Text("Already have an account?")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(Color.charcoal)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.white, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 15, style: .continuous)
                                    .stroke(Color.mediumMint.opacity(0.35), lineWidth: 1.5)
                            )
                    }
                }
                .padding(usesCompactLayout ? 20 : 24)
                .background((Color.white), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: Color.charcoal.opacity(0.08), radius: 20, y: 12)
                .padding(.bottom, 24)
            }
            
        }
        .padding(.horizontal, 22)
        .background(Color.whiteMint)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var firstNameField: some View {
        AuthTextField(
            title: "First Name",
            text: $firstName,
            prompt: "First Name",
            systemImage: "person.fill",
            validationMessage: nil
        )
    }

    private var lastNameField: some View {
        AuthTextField(
            title: "Last Name",
            text: $lastName,
            prompt: "Last Name",
            systemImage: "person.fill",
            validationMessage: nil
        )
    }

    private func signUp() {
        errorMessage = nil

        guard !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Enter your first name."
            return
        }

        guard !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Enter your last name."
            return
        }

        guard Validator.validateEmail(emailText) else {
            errorMessage = "Enter a valid email address."
            return
        }

        guard Validator.validatePassword(passwordText) else {
            errorMessage = "Your password needs 8+ characters, 1 uppercase, 1 number, and 1 symbol."
            return
        }

        guard confirmPasswordText == passwordText else {
            errorMessage = "Passwords need to match."
            return
        }

        isLoading = true

        Task {
            do {
                let user = try await authService.signUp(
                    firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
                    lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
                    email: emailText,
                    password: passwordText
                )
                isLoading = false
                appSession.signIn(as: user)
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
}

#Preview {
    NavigationStack {
        RegistrationView()
            .environmentObject(AppSession())
    }
}
