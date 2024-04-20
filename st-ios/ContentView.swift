//
//  ContentView.swift
//  st-ios
//
//  Created by Raphaël Tournafond on 17/04/2024.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var bluetoothManager = BluetoothManager()
    @State private var lastUUID: String? = nil
    @State private var lastName: String? = nil

    var body: some View {
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

