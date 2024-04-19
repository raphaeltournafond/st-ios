//
//  TrackingView.swift
//  st-ios
//
//  Created by Raphaël Tournafond on 18/04/2024.
//

import SwiftUI

struct TrackingView: View {
    @ObservedObject var bluetoothManager: BluetoothManager
    @State private var isTracking = false
    @State private var isConnecting = true
    @State private var isConnected = false
    let deviceUUID: String

    var body: some View {
        VStack {
            if isConnecting {
                ProgressView("Connecting to \(deviceUUID)")
                    .padding()
            } else {
                if isConnected {
                    Text("Connected to \(bluetoothManager.connectedPeripheral?.name ?? "device")")
                        .padding()
                    
                    if !isTracking {
                        ButtonView(action: {
                            startTracking()
                        }, text: "Start tracking", background: .green)
                        
                        ButtonView(action: {
                            bluetoothManager.removeLastConnectedUUID()
                        }, text: "Forget device")
                        
                    } else {
                        ScrollView {
                            VStack {
                                ForEach(bluetoothManager.receivedData, id: \.self) { data in
                                    Text(data)
                                }
                            }
                        }
                        ButtonView(action: {
                            stopTracking()
                        }, text: "Stop tracking", background: .red)
                    }
                } else {
                    Text("Couldn't connect to \(bluetoothManager.connectedPeripheral?.name ?? "device")")
                        .padding()
                    
                    ButtonView(action: {
                        bluetoothManager.removeLastConnectedUUID()
                    }, text: "Try again")
                    
                    ButtonView(action: {
                        bluetoothManager.removeLastConnectedUUID()
                    }, text: "Try another device")
                }
            }
        }.onAppear {
            tryConnecting()
        }
    }
    
    func tryConnecting() {
        bluetoothManager.connect(withUUID: deviceUUID) { success in
            if success {
                isConnecting = false
                isConnected = true
            } else {
                isConnecting = false
                isConnected = false
            }
        }
    }

    func startTracking() {
        isTracking = true
        bluetoothManager.isTracking = true
    }
    
    func stopTracking() {
        isTracking = false
        bluetoothManager.isTracking = false
    }
}
