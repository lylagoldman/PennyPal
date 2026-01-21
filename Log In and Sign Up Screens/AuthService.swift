import Foundation

protocol AuthServicing {
    func signIn(email: String, password: String) async throws
}

enum AuthError: LocalizedError {
    case invalidCredentials
    case network
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidCredentials: return "Invalid email or password."
        case .network: return "Network error. Please try again."
        case .unknown: return "Something went wrong. Please try again."
        }
    }
}

struct AuthService: AuthServicing {
    func signIn(email: String, password: String) async throws {
        // Simulate network latency
        try await Task.sleep(nanoseconds: 800_000_000)

        // Replace this with real authentication logic
        if email.lowercased() == "test@example.com", password == "Password123" {
            return
        } else {
            throw AuthError.invalidCredentials
        }
    }
}
