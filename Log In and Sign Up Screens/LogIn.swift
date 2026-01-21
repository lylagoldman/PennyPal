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
    @EnvironmentObject private var session: AppSession
    @State private var emailText = ""
    @State private var passwordText = ""

    @State private var isValidEmail = true
    @State private var isValidPassword = true
    
    var canProceed: Bool {
        Validator.validateEmail(emailText) && Validator.validatePassword(passwordText)
    }
    
    @FocusState private var focusedField: FocusedField?

    var body: some View {
        NavigationStack {
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
                            EmailTextField(emailText: $emailText, isValidEmail: $isValidEmail)
                            
                            PasswordTextField(passwordText: $passwordText, isValidPassword: $isValidPassword, validatePassword: Validator.validatePassword, errorText: "Your passowrd is invalid", placeholder: "Password")
                            
                            HStack {
                                Spacer()
                                Button {
                                    //action for forgot password
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
                            .padding(.vertical, 10)
                        
                            Button {
                                
                            } label: {
                                Text("Create New Account")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.black)
                                    .padding(.vertical, 5)
                                
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 100)
                        }
                        .padding(.bottom, 300)
                    }
                    
                }
                .padding(.top, 200)
            }
        }
    
    }
}
struct EmailTextField: View {
    @Binding var emailText: String
    @Binding var isValidEmail: Bool

    @FocusState var focusedField: FocusedField?
    var body: some View {
        VStack {
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
                .onChange(of: emailText) { oldValue, newValue in
                    emailText = newValue
                    // Simple validation example; adjust to your app's rules
                    isValidEmail = newValue.contains("@") && newValue.contains(".")
                }
                .padding(.bottom, isValidEmail ? 16 : 0)
            if !isValidEmail {
                HStack {
                    Text("Your email is invalid")
                        .foregroundStyle(Color(.red))
                }
                .padding(.bottom, 5)
            }
        }
    }
}

struct PasswordTextField: View {
    @Binding var passwordText: String
    @Binding var isValidPassword: Bool
    let validatePassword: (String) -> Bool
    let errorText: String
    let placeholder: String
    
    @FocusState var focusedField: FocusedField?
    var body: some View {
        VStack {
            SecureField(placeholder, text: $passwordText)
                .focused($focusedField, equals: .password)
                .padding()
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                .background(Color(.lightMint))
                .cornerRadius(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(!isValidPassword ? .red : focusedField == .password ? Color(.charcoal) : .white, lineWidth: 3)
                )
                .padding(.horizontal, 30)
                .padding(.vertical, 5)
                .onChange(of: passwordText) { oldValue, newValue in
                    isValidPassword = Validator.validatePassword(newValue)
                }
                .padding(.bottom, isValidPassword ? 16 : 0)
            if !isValidPassword {
                HStack {
                    Text(errorText)
                        .foregroundStyle(Color(.red))
                }
                .padding(.bottom, 5)
            }
        }
    }
}

#Preview {
    LogIn()
}
