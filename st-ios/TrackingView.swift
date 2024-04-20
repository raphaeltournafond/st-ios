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
    @State private var isConnecting = false
    @State private var connectionError = false
    @State private var askForScanning = false
    @State private var showForgetAlert = false
    let deviceUUID: String

    var body: some View {
        VStack {
            if askForScanning {
                ScanningView(bluetoothManager: bluetoothManager)
            } else if isConnecting {
                ProgressView("Connecting to \(deviceUUID)")
                    .padding()
            } else {
                if !connectionError {
                    
                    if !isTracking {
                        Text("\(bluetoothManager.targetPeripheral?.name ?? "Device") selected for tracking")
                            .padding()
                        
                        ButtonView(action: {
                            startTracking()
                        }, text: "Start tracking", background: .green)
                        
                        Button(action: {
                            showForgetAlert = true
                        }) {
                            Text("Forget device")
                        }
                        .alert(isPresented: $showForgetAlert) {
                            Alert(
                                title: Text("Are you sure?"),
                                message: Text("This action will forget the device."),
                                primaryButton: .destructive(Text("Forget")) {
                                    forgetAndScan()
                                },
                                secondaryButton: .cancel()
                            )
                        }
                        
                    } else {
                        Text("Connected to \(bluetoothManager.connectedPeripheral?.name ?? "device")")
                            .padding()
                        
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
                    Text("Couldn't connect to \(bluetoothManager.targetPeripheral?.name ?? "device")")
                        .padding()
                    
                    ButtonView(action: {
                        tryConnecting()
                    }, text: "Try again")
                    
                    Button(action: {
                        showForgetAlert = true
                    }) {
                        Text("Select another device")
                    }
                    .alert(isPresented: $showForgetAlert) {
                        Alert(
                            title: Text("Confirm?"),
                            message: Text("You will be redirected to the scanning screen"),
                            primaryButton: .default(Text("OK")) {
                                forgetAndScan()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
            }
        }
    }
    
    func tryConnecting() {
        isConnecting = true
        connectionError = false
        bluetoothManager.connect(withUUID: deviceUUID) { success in
            if success {
                isConnecting = false
            } else {
                isConnecting = false
                connectionError = true
            }
        }
    }

    func startTracking() {
        tryConnecting()
        isTracking = true
        bluetoothManager.isTracking = true
    }
    
    func stopTracking() {
        bluetoothManager.disconnectFromPeripheral()
        isTracking = false
        bluetoothManager.isTracking = false
    }
    
    func forgetAndScan() {
        bluetoothManager.forgetLastConnectedUUID()
        askForScanning = true
    }
}
