//
//  LaunchView.swift
//  PennyPal
//
//  Created by Lyla Goldman on 12/31/25.
//

import SwiftUI

struct LaunchView: View {
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            VStack {
                HLogoView()
                Text("For students who make every cent count.")
                    .fontWeight(.bold)
                    .font(.system(size: 13))
                    .foregroundColor(.charcoal)
                    .padding(.bottom, 5)
    
                ButtonView(title: "Log In", buttonColor: .mediumMint, newScreen: AnyView(LogIn()))
                    .padding(.bottom, 5)
                ButtonView(title: "Sign Up", buttonColor: .lightMint, newScreen: AnyView(RegistrationView()))
                    .padding(.bottom, 5)
            }
            .padding()
        }
    }
    
}


#Preview {
    LaunchView()
}
