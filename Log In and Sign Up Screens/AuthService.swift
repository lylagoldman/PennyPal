import Foundation

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
        case .invalidCredentials: return "Invalid email or password."
        case .emailAlreadyInUse: return "That email already has an account."
        case .network: return "Network error. Please try again."
        case .unknown: return "Something went wrong. Please try again."
        }
    }
}

struct AuthService: AuthServicing {
    func signIn(email: String, password: String) async throws -> UserProfile {
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

    func signUp(firstName: String, lastName: String, email: String, password: String) async throws -> UserProfile {
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
