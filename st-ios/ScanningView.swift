//
//  ScanningView.swift
//  st-ios
//
//  Created by Raphaël Tournafond on 18/04/2024.
//

import SwiftUI

struct ScanningView: View {
    @ObservedObject var bluetoothManager: BluetoothManager
    @State private var isScanning = false
    @State private var timer: Timer?
    @State private var selectedDeviceUUID: String? = nil
    @State private var selectedDeviceName: String? = nil

    var body: some View {
        if let deviceUUID = selectedDeviceUUID, let deviceName = selectedDeviceName {
            TrackingView(bluetoothManager: bluetoothManager, deviceUUID: deviceUUID, deviceName: deviceName)
        } else {
            VStack {
                Text("Smart Tracker")
                    .font(.largeTitle)
                    .padding(.bottom, 30)
                
                ButtonView(action: {
                    toggleScan()
                },
                text: isScanning ? "Cancel" : "Start Scanning",
                           textColor: bluetoothManager.bluetoothState == .poweredOn ? Color.white : Color.secondary,
                           background: bluetoothManager.bluetoothState == .poweredOn ? Color.blue : Color.accentColor
                ).disabled(bluetoothManager.bluetoothState != .poweredOn)
                
                if bluetoothManager.bluetoothState != .poweredOn {
                    Text(bluetoothManager.stateMessage)
                        .foregroundStyle(.red)
                }

                List(bluetoothManager.peripherals, id: \.self) { peripheral in
                    Button(action: {
                        selectedDeviceUUID = peripheral.identifier.uuidString
                        selectedDeviceName = peripheral.name ?? "Device"
                    }) {
                        Text(peripheral.identifier.uuidString + " - " + (peripheral.name ?? "Unnamed device")).foregroundStyle(Color.black)
                    }
                }
                
                if isScanning {
                    ProgressView("Scanning...")
                        .padding()
                }
            }
            .onDisappear {
                self.timer?.invalidate()
                self.timer = nil
            }
        }
    }

    func startScanning() {
        bluetoothManager.peripherals.removeAll()
        isScanning = true
        bluetoothManager.startScanning()
    }

    func stopScanning() {
        isScanning = false
        bluetoothManager.stopScanning()
        print(bluetoothManager.peripherals.count)
    }

    func toggleScan() {
        if isScanning {
            stopScanning()
        } else {
            startScanning()
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                self.stopScanning()
            }
        }
    }
}

struct ScanningView_Previews: PreviewProvider {
    static var previews: some View {
        ScanningView(bluetoothManager: BluetoothManager())
    }
}
