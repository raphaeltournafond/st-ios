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
    @State private var isConnected: Bool?

    var body: some View {
        // Check if isConnected
        if isConnected == nil {
            // determine the connection status
            ProgressView()
                .onAppear {
                    accountManager.isConnected { connected in
                        isConnected = connected
                    }
                }
        } else if isConnected == false {
            LoginView(accountManager: accountManager)
        } else {
            // isConnected
            NavigationStack {
                if let uuid = lastUUID, let name = lastName {
                    TrackingView(bluetoothManager: bluetoothManager, deviceUUID: uuid, deviceName: name)
                } else {
                    ScanningView(bluetoothManager: bluetoothManager)
                }
            }
            .onAppear {
                lastUUID = bluetoothManager.getLastConnectedUUID()
                lastName = bluetoothManager.getLastConnectedName()
            }
        }
    }
}

