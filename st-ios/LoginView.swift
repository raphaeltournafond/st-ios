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
    
    var body: some View {
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
            
            Button(action: {
                // Perform login action here
                print("Username: \(self.username), Password: \(self.password)")
            }) {
                Text("Login")
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(5.0)
            }
            Spacer()
        }
        .padding()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
