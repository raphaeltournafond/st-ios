//
//  ContentView.swift
//  st-ios
//
//  Created by Raphaël Tournafond on 17/04/2024.
//

import SwiftUI
import CoreBluetooth

// BluetoothManager class responsible for managing Bluetooth functionality.
class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    // Published properties to trigger UI updates when their values change.
    @Published var peripherals: [CBPeripheral] = []
    @Published var stateMessage: String = ""
    var bluetoothState: CBManagerState = .unknown // Track Bluetooth state
    var centralManager: CBCentralManager!
    var connectedPeripheral: CBPeripheral?

    // Initialize the Bluetooth manager and set the central manager delegate.
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
    
    // Handle Bluetooth state updates.
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        peripherals.removeAll()
        bluetoothState = central.state
        switch central.state {
            
        case .unsupported:  stateMessage = "Bluetooth is not supported on your device"
        case .unauthorized: stateMessage = "Please allow this app to use your device Bluetooth"
        case .unknown:      stateMessage = "Unknown error, scanning not possible, restart your device Bluetooth"
        case .resetting:    stateMessage = "Bluetooth is resetting... Please wait"
        case .poweredOff:   stateMessage = "Please turn ON your Bluetooth"
            
        case .poweredOn:
            stateMessage = "Bluetooth ON and ready for scanning"
        @unknown default:
            stateMessage = "Bluetooth not available, restart your device and try again"
        }
        print(stateMessage)
    }

    // Handle the discovery of a peripheral.
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !peripherals.contains(peripheral) {
            peripherals.append(peripheral)
        }
    }
    
    func connect(to peripheral: CBPeripheral) {
        print("connecting to \(peripheral.name ?? "Unknown")")
        centralManager.connect(peripheral, options: nil)
    }
    
    // Handle successful connection to a peripheral.
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

    // Handle the discovery of characteristics for a service on a peripheral.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            if characteristic.properties.contains(.read) {
                DispatchQueue.global().async {
                    peripheral.readValue(for: characteristic)
                }
            }
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        DispatchQueue.main.async {
            if let data = characteristic.value {
                let valueString = String(data: data, encoding: .utf8) ?? "Unable to convert data to String"
                print("Received data: \(valueString)")
            }
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
