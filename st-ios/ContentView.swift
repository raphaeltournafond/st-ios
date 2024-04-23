//
//  ContentView.swift
//  st-ios
//
//  Created by Raphaël Tournafond on 17/04/2024.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var bluetoothManager = BluetoothManager()
    @ObservedObject var accountManager = AccountManager()
    @State private var lastUUID: String? = nil
    @State private var lastName: String? = nil

    var body: some View {
        // Check if isConnected
        if accountManager.isConnected == nil {
            // determine the connection status
            ProgressView()
                .onAppear {
                    accountManager.checkConnection { connected in
                        print("Connexion status: \(connected)")
                    }
                }
        } else if accountManager.isConnected == false {
            LoginView(accountManager: accountManager)
        } else {
            // isConnected
            NavigationStack {
                if let uuid = lastUUID, let name = lastName {
                    TrackingView(bluetoothManager: bluetoothManager, accountManager: accountManager, deviceUUID: uuid, deviceName: name)
                } else {
                    ScanningView(bluetoothManager: bluetoothManager, accountManager: accountManager)
                }
            }
            .onAppear {
                lastUUID = bluetoothManager.getLastConnectedUUID()
                lastName = bluetoothManager.getLastConnectedName()
            }
        }
    }
}

