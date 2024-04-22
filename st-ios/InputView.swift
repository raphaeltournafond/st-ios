//
//  InputText.swift
//  st-ios
//
//  Created by Raphaël Tournafond on 22/04/2024.
//

import SwiftUI

struct InputView: View {
    let name: String
    @Binding var field: String
    
    init(name: String, field: Binding<String>) {
        self.name = name
        self._field = field
    }
    
    var body: some View {
        TextField(name, text: $field)
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(15.0)
            .padding(.bottom, 10)
    }
}
