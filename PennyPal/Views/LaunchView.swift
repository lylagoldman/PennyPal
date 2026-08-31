//
//  LaunchView.swift
//  PennyPal
//
//  Created by Lyla on 12/31/25.
//


import SwiftUI

struct LaunchView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.whiteMint
                    .ignoresSafeArea()
                
                VStack {
                    Image("HLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.horizontal, 10)
                    
                    
                    Text("For students who make every cent count.")
                        .fontWeight(.bold)
                        .font(.system(size: 16))
                        .foregroundColor(.charcoal)
                        .padding(.bottom, 15)
                    
                    NavigationLink(destination: LogIn()) {
                        Text("Log In")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color.charcoal)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.mediumMint, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                    }
                    .padding(.horizontal, 40)
                    
                    NavigationLink(destination: RegistrationView()) {
                        Text("Sign Up")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.charcoal, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                    }
                    .padding(.horizontal, 40)
                }
                .padding()
            }
        }
    }
}
    
#Preview {
    LaunchView()
}
