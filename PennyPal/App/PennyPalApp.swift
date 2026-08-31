//
//  PennyPalApp.swift
//  PennyPal
//

import SwiftUI
import Foundation
import FirebaseCore

@main
struct PennyPalApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
