//
//  ContentView.swift
//  PennyPal
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
