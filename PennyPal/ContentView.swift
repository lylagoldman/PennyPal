//
//  ContentView.swift
//  PennyPal
//
//  Created by Lyla on 10/24/25.
//
import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var appSession = AppSession()

    var body: some View {
        Group {
            if appSession.isLoggedIn, let currentUser = appSession.currentUser {
                NavigationStack {
                    HomeView(user: currentUser)
                }
                .id("logged-in")
            } else {
                NavigationStack {
                    LaunchView()
                }
                .id("logged-out")
            }
        }
        .environmentObject(appSession)
    }
}

#Preview {
    ContentView()
}

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
