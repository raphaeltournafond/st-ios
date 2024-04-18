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
                        Button(action: {
                            startTracking()
                        }) {
                            Text("Start Tracking")
                                .padding()
                                .background(Color.green)
                                .foregroundColor(Color.white)
                                .cornerRadius(10)
                        }
                        .padding()
                    } else {
                        ScrollView {
                            VStack {
                                ForEach(bluetoothManager.receivedData, id: \.self) { data in
                                    Text(data)
                                }
                            }
                        }
                        Button(action: {
                            stopTracking()
                        }) {
                            Text("Stop Tracking")
                                .padding()
                                .background(Color.red)
                                .foregroundColor(Color.white)
                                .cornerRadius(10)
                        }
                    }
                } else {
                    Text("Couldn't connect to \(bluetoothManager.connectedPeripheral?.name ?? "device")")
                        .padding()
                    
                    Button(action: {
                        tryConnecting()
                    }) {
                        Text("Try Again")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(Color.white)
                            .cornerRadius(10)
                    }
                    .padding()
                    
                    Button(action: {
                        bluetoothManager.removeLastConnectedUUID()
                    }) {
                        Text("Scan for another device")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(Color.white)
                            .cornerRadius(10)
                    }
                    .padding()
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
