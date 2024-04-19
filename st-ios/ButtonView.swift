//
//  ButtonView.swift
//  st-ios
//
//  Created by Raphaël Tournafond on 19/04/2024.
//

import SwiftUI

struct ButtonView: View {
    let action: () -> Void
    let text: String
    let textColor: Color = Color.white
    let background: Color = Color.blue
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .padding()
                .background(background)
                .foregroundColor(textColor)
                .cornerRadius(10)
        }
        .padding()
    }
}
