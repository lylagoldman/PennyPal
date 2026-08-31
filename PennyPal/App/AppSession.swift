import Foundation
import Combine

@MainActor
final class AppSession: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: UserProfile?

    func signIn(as user: UserProfile) {
        currentUser = user
        isLoggedIn = true
    }

    func signOut() {
        currentUser = nil
        isLoggedIn = false
    }
}
