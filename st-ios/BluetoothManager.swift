//
//  BluetoothManager.swift
//  st-ios
//
//  Created by Raphaël Tournafond on 18/04/2024.
//
import Foundation
import CoreBluetooth

// BluetoothManager class responsible for managing Bluetooth functionality.
class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    // Published properties to trigger UI updates when their values change.
    @Published var peripherals: [CBPeripheral] = []
    @Published var stateMessage: String = ""
    @Published var receivedData: [String] = []
    @Published var lastData: String? = nil
    @Published var bluetoothState: CBManagerState = .unknown // Track Bluetooth state
    @Published var connectedPeripheral: CBPeripheral?
    @Published var targetPeripheral: CBPeripheral?
    @Published var isTracking: Bool = false
    private var centralManager: CBCentralManager!
    private var targetPeripheralUUID: String?
    private var onBluetoothStateUpdate: ((CBManagerState) -> Void)?
    private let userDefaultsUUIDKey = "lastConnectedDeviceUUID"
    private let userDefaultsNameKey = "lastConnectedDeviceName"
    private let powerOnTimeoutInterval: Double = 3.0
    private let connectionTimeoutInterval: Double = 10.0

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
        onBluetoothStateUpdate?(central.state)
    }

    // Handle the discovery of a peripheral.
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral.identifier.uuidString + " - " + (targetPeripheralUUID ?? "Nil"))
        if targetPeripheralUUID != nil {
            if peripheral.identifier.uuidString == targetPeripheralUUID {
                targetPeripheral = peripheral
                centralManager.stopScan()
                connect(to: peripheral)
            }
        } else {
            // Store a reference to the discovered peripheral
            if !peripherals.contains(peripheral) {
                peripherals.append(peripheral)
                // Keep a reference to the peripheral
                targetPeripheral = peripheral
            }
        }
    }
    
    func connect(withUUID uuid: String, completion: @escaping (Bool) -> Void) {
        disconnectFromPeripheral()
        // Check if Bluetooth is powered on
        guard centralManager.state == .poweredOn else {
            // Bluetooth is not powered on, wait for it to become powered on
            var elapsedTime = 0.0
            _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                elapsedTime += 1.0
                if self.centralManager.state == .poweredOn {
                    timer.invalidate()
                    self.connect(withUUID: uuid, completion: completion)
                } else if elapsedTime >= self.powerOnTimeoutInterval {
                    timer.invalidate()
                    completion(false) // Timeout reached, notify completion handler of failure
                }
            }
            return
        }

        // Bluetooth is powered on, proceed with connection
        targetPeripheralUUID = uuid
        centralManager.scanForPeripherals(withServices: nil, options: nil)

        // Start timer to handle timeout
        let timeoutDate = Date().addingTimeInterval(connectionTimeoutInterval)
        // Check for connection or timeout asynchronously
        DispatchQueue.global().async {
            var isConnected = false
            while !isConnected && Date() < timeoutDate {
                if self.connectedPeripheral != nil {
                    isConnected = true
                } else {
                    // Wait for a short interval before checking again
                    Thread.sleep(forTimeInterval: 0.1)
                }
            }
            self.centralManager.stopScan()

            // Return success or failure based on isConnected
            DispatchQueue.main.async {
                completion(isConnected)
            }
        }
    }

    
    func connect(to peripheral: CBPeripheral) {
        disconnectFromPeripheral()
        receivedData = []
        print("connecting to \(peripheral.name ?? "Unknown")")
        centralManager.connect(peripheral, options: nil)
    }
    
    func disconnectFromPeripheral() {
        if let peripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
            print("Disconnected from : \(peripheral.name ?? "Unknown")")
        }
        connectedPeripheral = nil
    }
    
    // Handle successful connection to a peripheral.
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to peripheral: \(peripheral)")
        connectedPeripheral = peripheral
        UserDefaults.standard.set(peripheral.identifier.uuidString, forKey: userDefaultsUUIDKey)
        UserDefaults.standard.set(peripheral.name ?? "Device", forKey: userDefaultsNameKey)
        connectedPeripheral?.delegate = self
        connectedPeripheral?.discoverServices(nil)
    }
    
    func getLastConnectedUUID() -> String? {
        let lastUUID = UserDefaults.standard.string(forKey: userDefaultsUUIDKey)
        print("Last connected device: \(lastUUID ?? "None")")
        return lastUUID
    }
    
    func getLastConnectedName() -> String? {
        let lastName = UserDefaults.standard.string(forKey: userDefaultsNameKey)
        print("Last connected device: \(lastName ?? "None")")
        return lastName
    }
    
    func forgetLastConnectedUUID() {
        UserDefaults.standard.removeObject(forKey: userDefaultsUUIDKey)
        targetPeripheralUUID = nil
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
                self.lastData = valueString
                self.receivedData.append(valueString)
            }
        }
    }
}
