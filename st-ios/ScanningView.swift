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

    var body: some View {
        VStack {
            Text("Smart Tracker")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding()
            Button(action: {
                self.toggleScan()
            }) {
                Text(isScanning ? "Stop Scanning" : "Start Scanning")
                    .padding()
                    .background(bluetoothManager.bluetoothState == .poweredOn ? Color.blue : Color.gray)
                    .foregroundColor(bluetoothManager.bluetoothState == .poweredOn ? Color.white : Color.black)
                    .cornerRadius(10)
            }
            .padding()
            .disabled(bluetoothManager.bluetoothState != .poweredOn)
            
            if bluetoothManager.bluetoothState != .poweredOn {
                Text(bluetoothManager.stateMessage)
                    .italic()
                    .foregroundStyle(Color.gray)
            }

            if isScanning {
                ProgressView("Scanning...")
                    .padding()
            }

            List(bluetoothManager.peripherals, id: \.self) { peripheral in
                Button(action: {
                    bluetoothManager.connect(to: peripheral)
                }) {
                    Text(peripheral.identifier.uuidString + " - " + (peripheral.name ?? "Unknown name"))
                }
            }
        }
        .onDisappear {
            self.timer?.invalidate()
            self.timer = nil
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
