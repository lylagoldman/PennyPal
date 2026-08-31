//
//  FirebaseAuthService.swift
//  PennyPal
//

import Foundation
import FirebaseAuth

protocol AuthServicing {
    func signIn(email: String, password: String) async throws -> UserProfile
    func signUp(firstName: String, lastName: String, email: String, password: String) async throws -> UserProfile
    func resetPassword(email: String) async throws
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

struct FirebaseAuthService: AuthServicing {
    func signIn(email: String, password: String) async throws -> UserProfile {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        let firebaseUser = result.user
        
        return UserProfile(
            firstName: "", // Firebase doesn't store names by default
            lastName: "",  // see note below
            email: firebaseUser.email ?? email,
            preferredCurrency: "$",
            joinedDate: firebaseUser.metadata.creationDate ?? .now
        )
    }

    func signUp(firstName: String, lastName: String, email: String, password: String) async throws -> UserProfile {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let firebaseUser = result.user
        
        return UserProfile(
            firstName: firstName,
            lastName: lastName,
            email: firebaseUser.email ?? email,
            preferredCurrency: "$",
            joinedDate: .now
        )
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
}
