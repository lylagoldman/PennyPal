//
//  SignUp.swift
//  PennyPal
//
//  Created by Lyla Goldman on 10/30/25.
//

import SwiftUI

struct RegistrationView: View {
    @State private var emailText = ""
    @State private var passwordText = ""
    @State private var confirmPasswordText = ""

    @State private var isValidEmail = true
    @State private var isValidPassword = true
    @State private var isConfirmPasswordValid = true

    
    var canProceed: Bool {
        Validator.validateEmail(emailText) && Validator.validatePassword(passwordText) && validateConfirm(confirmPasswordText)
    }
    
    @FocusState private var focusedField: FocusedField?
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundA()
                VStack {
                    Text("Create Account")
                        .font(.system(size: 32))
                        .fontWeight(.bold)
                        .frame(maxHeight: .infinity, alignment: .center)
                        .padding(40)
                    ZStack {
                        RoundedRectangle(cornerRadius: 75)
                            .frame(height: 800, alignment: .center)
                            .foregroundColor(.whiteMint)
                        VStack {
                            Text("Enter your credentials to create an account")
                                .font(.system(size: 15))
                                .fontWeight(.medium)
                                .padding(40)
                            

                            EmailTextField(emailText: $emailText, isValidEmail: $isValidEmail)
                            
                            PasswordTextField(passwordText: $passwordText, isValidPassword: $isValidPassword, validatePassword: Validator.validatePassword, errorText: "Your password must be at least 8 characters long", placeholder: "Password")
                            
                            PasswordTextField(passwordText: $confirmPasswordText, isValidPassword: $isConfirmPasswordValid,validatePassword: validateConfirm, errorText: "Your passwords must match", placeholder: "Confirm Password")
                            
                            Button {
                                //action
                            } label: {
                                Text("Sign Up")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.charcoal)
                            }
                            .padding(.vertical, 15)
                            .frame(maxWidth: .infinity)
                            .background(Color(.mediumMint))
                            .cornerRadius(20)
                            .padding(.horizontal, 80)
                            .opacity(canProceed ? 1 : 0.6)
                            .disabled(!canProceed)
                            .padding(.vertical, 5)
                        
                            Button {
                                // action for log in
                            } label: {
                                Text("Already have an account?")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black)
                                    .padding(.vertical, 5)
                                
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 80)
                        }
                        .padding(.bottom, 200)
                    }
                    
                }
                .padding(.top, 200)
            }
        }
    }
    
    func validateConfirm(_ password: String) -> Bool {
        passwordText == password
    }
}

#Preview {
    RegistrationView()
}
