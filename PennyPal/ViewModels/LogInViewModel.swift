import SwiftUI
import Combine

@MainActor
final class LogInViewModel: ObservableObject {
    @Published var emailText = ""
    @Published var passwordText = ""
    @Published var isValidEmail = true
    @Published var isValidPassword = true
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let auth: AuthServicing

    init(auth: AuthServicing) {
        self.auth = auth
    }

    @MainActor
    convenience init() {
        self.init(auth: FirebaseAuthService())
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
        guard Validator.validateEmail(emailText), Validator.validatePassword(passwordText) else { return }
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
    
    func sendPasswordReset() {
        guard Validator.validateEmail(emailText) else {
            errorMessage = "Enter your email address first."
            return
        }
        Task {
            do {
                try await auth.resetPassword(email: emailText)
                // maybe set a success message here
            } catch {
                errorMessage = "Could not send reset email. Try again."
            }
        }
    }
}


   
