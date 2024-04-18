//
//  ContentView.swift
//  st-ios
//
//  Created by Raphaël Tournafond on 17/04/2024.
//

import SwiftUI
import CoreBluetooth

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    @Published var peripherals: [CBPeripheral] = []
    var centralManager: CBCentralManager!
    var connectedPeripheral: CBPeripheral?

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
        switch (central.state) {
            
        case .unsupported:  print("CoreBluetooth BLE hardware is unsupported on this platform")
        case .unauthorized: print("CoreBluetooth BLE state is unauthorized")
        case .unknown:      print("CoreBluetooth BLE state is unknown")
        case .resetting:    print("CoreBluetooth BLE is resetting")
        case .poweredOff:   print("CoreBluetooth BLE hardware is powered off")
            
        case .poweredOn:
            print("CoreBluetooth BLE hardware is powered on and ready")
        @unknown default:
            print("Bluetooth not available")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !peripherals.contains(peripheral) {
            peripherals.append(peripheral)
        }
    }
    
    func connect(to peripheral: CBPeripheral) {
        print("connecting to \(peripheral.name ?? "Unknown")")
        centralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to peripheral: \(peripheral)")
        connectedPeripheral = peripheral
        connectedPeripheral?.delegate = self
        connectedPeripheral?.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
            guard let services = peripheral.services else { return }
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.properties.contains(.read) {
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value {
            let valueString = String(data: data, encoding: .utf8) ?? "Unable to convert data to String"
            print("Received data: \(valueString)")
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
                Button(action: {
                    bluetoothManager.connect(to: peripheral)
                }) {
                    Text(peripheral.identifier.uuidString + " - " + (peripheral.name ?? "Unknown name"))
                }
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
            self.timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                self.stopScanning()
            }
        }
    }
}
