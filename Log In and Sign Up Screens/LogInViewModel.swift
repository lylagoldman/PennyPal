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
        self.init(auth: AuthService())
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

    func signIn(onSuccess: @escaping () -> Void) {
        errorMessage = nil
        guard Validator.validateEmail(emailText), Validator.validatePassword(passwordText) else { return }
        isLoading = true

        Task {
            do {
                try await auth.signIn(email: emailText, password: passwordText)
                isLoading = false
                onSuccess()
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

