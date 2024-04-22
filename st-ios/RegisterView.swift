//
//  RegisterView.swift
//  st-ios
//
//  Created by Raphaël Tournafond on 19/04/2024.
//

import SwiftUI

struct RegisterView: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var openLogin: Bool = false
    @State private var registeredIn: Bool = false
    @State private var registerFailed: Bool = false
    private var accountManager: AccountManager
    
    init(accountManager: AccountManager) {
        self.accountManager = accountManager
    }
    
    var body: some View {
        if openLogin {
            LoginView(accountManager: accountManager)
        } else {
            VStack {
                Spacer()
                Text("Smart Tracker")
                    .font(.largeTitle)
                    .padding(.bottom, 30)
                Spacer()
                
                HStack {
                    InputView(name: "First Name", field: $firstName)
                    
                    InputView(name: "Last Name", field: $lastName)
                }
                
                InputView(name: "Username", field: $username)
                    .textInputAutocapitalization(.never)
                
                InputView(name: "Email", field: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(15.0)
                    .padding(.bottom, 10)
                
                ButtonView(action: {
                    print("First Name: \(self.firstName), Last Name: \(self.lastName), Email: \(self.email), Username: \(self.username), Password: \(self.password)")
                    registerFailed = false
                    accountManager.register(firstName: firstName, lastName: lastName, email: email, username: username, password: password) { result in
                        switch result {
                        case .success(let isRegistered):
                            if isRegistered {
                                print("Register successful")
                                registeredIn = true
                            } else {
                                print("Register failed")
                                registerFailed = true
                            }
                        case .failure(let error):
                            print("Error during register: \(error)")
                            registerFailed = true
                        }
                    }
                }, text: "Register")
                
                Button(action: {
                    openLogin = true
                }) {
                    Text("Have an account? Login")
                }
                
                Spacer() // Pushing the button to the bottom
            }
            .padding()
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(accountManager: AccountManager())
    }
}
