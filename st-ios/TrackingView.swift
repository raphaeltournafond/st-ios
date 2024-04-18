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
    let deviceUUID: String

    var body: some View {
        VStack {
            if isConnecting {
                ProgressView("Connecting...")
                    .padding()
            } else {
                Text("Connected to \(bluetoothManager.connectedPeripheral?.identifier.uuidString ?? "device")")
                    .font(.title)
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
                                    .padding()
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
            }
        }.onAppear {
            bluetoothManager.connect(withUUID: deviceUUID)
        }
    }

    func startTracking() {
        isTracking = true
        // Start tracking logic here
    }
    
    func stopTracking() {
        isTracking = false
        // Stop tracking logic here
    }
}
