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
    
    var body: some View {
        if openRegister {
            RegisterView()
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
                    print("Username: \(self.username), Password: \(self.password)")
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
        LoginView()
    }
}
