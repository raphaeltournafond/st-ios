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
    let textColor: Color
    let background: Color
    
    init(action: @escaping () -> Void, text: String, textColor: Color = .white, background: Color = .blue) {
        self.action = action
        self.text = text
        self.textColor = textColor
        self.background = background
    }
    
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
