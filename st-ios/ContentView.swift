//
//  ContentView.swift
//  st-ios
//
//  Created by Raphaël Tournafond on 17/04/2024.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    @State private var peripherals: [CBPeripheral] = []
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
            
            Text("BLE peripherals").multilineTextAlignment(.trailing)

            List(peripherals, id: \.self) { peripheral in
                Text(peripheral.name ?? "Unknown")
            }
        }
        .onAppear {
            self.startScanning()
            self.timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { _ in
                self.stopScanning()
            }
        }
        .onDisappear {
            self.timer?.invalidate()
            self.timer = nil
        }
    }

    func startScanning() {
        isScanning = true
    }

    func stopScanning() {
        isScanning = false
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

var centralManager: CBCentralManager!

class BluetoothViewController: UIViewController {
    private var centralManager: CBCentralManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
}

extension BluetoothViewController: CBCentralManagerDelegate {
 
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
            case .poweredOn:
                centralManager.scanForPeripherals(withServices: nil)
            case .poweredOff:
                print("Please turn the Bluetooth ON")
            case .resetting:
                print("Resetting Bluetooth please wait")
            case .unauthorized:
                print("Please enable Bluetooth permission in app Settings")
            case .unsupported:
                print("Sorry, your device does not support Bluetooth and this app will not work as expected")
            case .unknown:
               print("Unknown Bluetooth state please wait")
            @unknown default:
                print("Unknown state")
        }
    }
}

#Preview {
    ContentView()
}
