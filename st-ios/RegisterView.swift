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
    @State private var password: String = ""
    @State private var openLogin: Bool = false
    
    var body: some View {
        if openLogin {
            LoginView()
        } else {
            VStack {
                Spacer()
                Text("Smart Tracker")
                    .font(.largeTitle)
                    .padding(.bottom, 30)
                Spacer()
                
                HStack {
                    TextField("First Name", text: $firstName)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(5.0)
                        .padding(.bottom, 20)
                    
                    TextField("Last Name", text: $lastName)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(5.0)
                        .padding(.bottom, 20)
                }
                
                TextField("Email", text: $email)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                    .keyboardType(.emailAddress)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                
                ButtonView(action: {
                    print("First Name: \(self.firstName), Last Name: \(self.lastName), Email: \(self.email), Password: \(self.password)")
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
        RegisterView()
    }
}
