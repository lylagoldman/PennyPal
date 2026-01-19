//
//  SignUp.swift
//  PennyPal
//
//  Created by Lyla Goldman on 10/30/25.
//

import SwiftUI

struct SignUp: View {
    @State private var emailText = ""
    @State private var passwordText = ""

    @State private var isValidEmail = true
    @State private var isValidPassword = true
    
    var canProceed: Bool {
        Validator.validateEmail(emailText) && Validator.validatePassword(passwordText)
    }
    
    @FocusState private var focusedField: FocusedField?
    
    var body: some View {
        ZStack {
            BackgroundA()
            VStack {
                Text("Login Here")
                    .font(.system(size: 32))
                    .fontWeight(.bold)
                    .frame(maxHeight: .infinity, alignment: .center)
                    .padding(40)
                ZStack {
                    RoundedRectangle(cornerRadius: 75)
                        .frame(height: 800, alignment: .center)
                        .foregroundColor(.whiteMint)
                    VStack {
                        Text("Welcome Back!")
                            .font(.system(size: 25))
                            .fontWeight(.bold)
                            .padding(40)
                        TextField("Email", text: $emailText)
                            .focused($focusedField, equals: .email)
                            .padding()
                            .disableAutocorrection(true)
                            .textInputAutocapitalization(.never)
                            .background(Color(.lightMint))
                            .cornerRadius(20)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(!isValidEmail ? .red : focusedField == .email ? Color(.charcoal) : .white, lineWidth: 3)
                            )
                            .padding(.horizontal, 30)
                    }
                }
            }
        }
    }
}
