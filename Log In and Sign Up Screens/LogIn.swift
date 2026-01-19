//
//  LogIn.swift
//  PennyPal
//
//  Created by Lyla Goldman on 12/31/25.
//

import SwiftUI
enum FocusedField {
    case email
    case password
}

struct LogIn: View {
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
                            .background(Color(.lightMint))
                            .cornerRadius(20)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(!isValidEmail ? .red :focusedField == .email ? Color(.charcoal) : .white, lineWidth: 3)
                            )
                            .padding(.horizontal, 30)
                            .onChange(of: emailText) { oldValue, newValue in
                                isValidEmail = Validator.validateEmail(newValue)
                             }
                            .padding(.bottom, isValidEmail ? 16 : 0)
                        if !isValidEmail {
                            HStack {
                                Text("Your email is invalid")
                                    .foregroundStyle(Color(.red))
                            }
                            .padding(.bottom)
                        }
                        
                        TextField("Password", text: $passwordText)
                            .focused($focusedField, equals: .password)
                            .padding()
                            .background(Color(.lightMint))
                            .cornerRadius(20)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(!isValidPassword ? .red : focusedField == .password ? Color(.charcoal) : .white, lineWidth: 3)
                            )
                            .padding(.horizontal, 30)
                            .padding(.top)
                            .onChange(of: passwordText) { oldValue, newValue in
                                isValidPassword = Validator.validatePassword(newValue)
                            }
                            .padding(.bottom, isValidPassword ? 16 : 0)
                        if !isValidPassword {
                            HStack {
                                Text("Your password is invalid")
                                    .foregroundStyle(Color(.red))
                            }
                            .padding(.bottom)
                        }
                        
                        HStack {
                            Spacer()
                            Button {
                                //action
                            } label: {
                                Text("Forgot your password?")
                                    .foregroundColor(Color.charcoal)
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .padding(.trailing, 35)
                            .padding(.vertical, 5)
                        }
                        
                        Button {
                            
                        } label: {
                            Text("Sign In")
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
                            
                        } label: {
                            Text("Create Accounnt")
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

#Preview {
    LogIn()
}
