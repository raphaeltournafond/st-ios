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

    var body: some View {
        NavigationStack {
            if lastUUID != nil {
                TrackingView(bluetoothManager: bluetoothManager, deviceUUID: lastUUID!)
            } else {
                ScanningView(bluetoothManager: bluetoothManager)
            }
        }
        .onAppear {
            lastUUID = bluetoothManager.getLastConnectedUUID()
        }
    }
}

