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
    @State private var openRegister: Bool = false
    @State private var loggedIn: Bool = false
    @State private var loginFailed: Bool = false
    private var accountManager: AccountManager
    
    init(accountManager: AccountManager) {
        self.accountManager = accountManager
    }
    
    var body: some View {
        if openRegister {
            RegisterView(accountManager: accountManager)
        } else if loggedIn {
            ContentView()
        } else {
            VStack {
                Spacer()
                Text("Smart Tracker")
                    .font(.largeTitle)
                    .padding(.bottom, 30)
                Spacer()
                
                InputView(name: "Username", field: $username)
                    .textInputAutocapitalization(.never)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(15.0)
                    .padding(.bottom, 10)
                
                if loginFailed {
                    Text("Login failed please try again").foregroundStyle(.red)
                }
                
                ButtonView(action: {
                    print("Login IN... username: \(self.username), password: \(self.password)")
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
        LoginView(accountManager: AccountManager())
    }
}
