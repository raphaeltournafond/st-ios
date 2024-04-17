//
//  ContentView.swift
//  st-ios
//
//  Created by Raphaël Tournafond on 17/04/2024.
//

import SwiftUI
import CoreBluetooth

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate {
    @Published var peripherals: [CBPeripheral] = []
    var centralManager: CBCentralManager!

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func startScanning() {
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func stopScanning() {
        centralManager.stopScan()
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanning()
        } else {
            print("Bluetooth not available")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !peripherals.contains(peripheral) {
            peripherals.append(peripheral)
        }
    }
}


struct ContentView: View {
    @ObservedObject var bluetoothManager = BluetoothManager()
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
                    .background(Color.blue)
                    .foregroundColor(Color.white)
                    .cornerRadius(10)
            }
            .padding()

            if isScanning {
                ProgressView("Scanning...")
                    .padding()
            }

            List(bluetoothManager.peripherals, id: \.self) { peripheral in
                Text(peripheral.name ?? "Unknown")
            }.navigationTitle("Peripherals")
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
            self.timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { _ in
                self.stopScanning()
            }
        }
    }
}

#Preview {
    ContentView()
}
