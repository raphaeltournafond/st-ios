//
//  DisconnectView.swift
//  st-ios
//
//  Created by Raphaël Tournafond on 23/04/2024.
//

import SwiftUI

struct DisconnectView: View {
    private var accountManager: BackendManager
    
    init(accountManager: BackendManager) {
        self.accountManager = accountManager
    }

    var body: some View {
        Button(action: {
            accountManager.disconnect()
        }) {
            Text("Disconnect")
                .foregroundColor(.red)
                .padding()
        }.padding()
    }
}

struct DisconnectView_Previews: PreviewProvider {
    static var previews: some View {
        DisconnectView(accountManager: BackendManager())
    }
}
