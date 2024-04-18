//
//  BluetoothManager.swift
//  st-ios
//
//  Created by Raphaël Tournafond on 18/04/2024.
//

import CoreBluetooth

// BluetoothManager class responsible for managing Bluetooth functionality.
class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    // Published properties to trigger UI updates when their values change.
    @Published var peripherals: [CBPeripheral] = []
    @Published var stateMessage: String = ""
    @Published var receivedData: [String] = []
    @Published var bluetoothState: CBManagerState = .unknown // Track Bluetooth state
    @Published var connectedPeripheral: CBPeripheral?
    private var centralManager: CBCentralManager!
    private var targetPeripheralUUID: String?
    private var targetPeripheral: CBPeripheral?
    private let userDefaultsUUIDKey = "lastConnectedDeviceUUID"

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
        case .unknown:      stateMessage = "Unknown error, Bluetooth usage not possible, restart your device"
        case .resetting:    stateMessage = "Bluetooth is resetting... Please wait"
        case .poweredOff:   stateMessage = "Please turn ON your Bluetooth"
            
        case .poweredOn:
            stateMessage = "Bluetooth ON and ready"
        @unknown default:
            stateMessage = "Bluetooth not available, restart your device and try again"
        }
        print(stateMessage)
    }

    // Handle the discovery of a peripheral.
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if targetPeripheralUUID != nil {
            if peripheral.identifier.uuidString == targetPeripheralUUID {
                centralManager.stopScan()
                connect(to: peripheral)
            }
        } else {
            if !peripherals.contains(peripheral) {
                peripherals.append(peripheral)
            }
        }
    }
    
    func connect(withUUID uuid: String) {
        targetPeripheralUUID = uuid
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func connect(to peripheral: CBPeripheral) {
        receivedData = []
        print("connecting to \(peripheral.name ?? "Unknown")")
        centralManager.connect(peripheral, options: nil)
    }
    
    // Handle successful connection to a peripheral.
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to peripheral: \(peripheral)")
        connectedPeripheral = peripheral
        UserDefaults.standard.set(peripheral.identifier.uuidString, forKey: userDefaultsUUIDKey)
        connectedPeripheral?.delegate = self
        connectedPeripheral?.discoverServices(nil)
    }
    
    func getLastConnectedUUID() -> String? {
        let lastUUID = UserDefaults.standard.string(forKey: userDefaultsUUIDKey)
        print("Last connected device: \(lastUUID ?? "None")")
        return lastUUID
    }
    
    func removeLastConnectedUUID() {
        UserDefaults.standard.removeObject(forKey: userDefaultsUUIDKey)
        print("Last connected device successfully removed")
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
                self.receivedData.append(valueString)
            }
        }
    }
}
