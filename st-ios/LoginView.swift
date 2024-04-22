//
//  LoginView.swift
//  st-ios
//
//  Created by Raphaël Tournafond on 19/04/2024.
//

import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var openRegister = false
    @State private var loggedIn = false
    @State private var loginFailed = false
    private var accountManager = AccountManager()
    
    var body: some View {
        if openRegister {
            RegisterView()
        } else if loggedIn {
            ContentView()
        } else {
            VStack {
                Spacer()
                Text("Smart Tracker")
                    .font(.largeTitle)
                    .padding(.bottom, 30)
                Spacer()
                
                TextField("Username", text: $username)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                
                ButtonView(action: {
                    loginFailed = false
                    accountManager.login(username: username, password: password) { result in
                        switch result {
                        case .success(let isAuthenticated):
                            if isAuthenticated {
                                print("Login successful")
                                loggedIn = true
                            } else {
                                print("Login failed")
                                loginFailed = true
                            }
                        case .failure(let error):
                            print("Error during login: \(error)")
                            loginFailed = true
                        }
                    }
                }, text: "Login")
                
                if loginFailed {
                    Text("Login failed please try again").foregroundStyle(.red)
                }
                
                Button(action: {
                    openRegister = true
                }) {
                    Text("No account? Register now")
                }
                Spacer()
            }
            .padding()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
