//
//  TrackingView.swift
//  st-ios
//
//  Created by Raphaël Tournafond on 18/04/2024.
//

import SwiftUI

struct TrackingView: View {
    @ObservedObject var bluetoothManager: BluetoothManager
    @ObservedObject var accountManager: BackendManager
    @StateObject var chartViewModel = ChartViewModel()
    @State private var isSessionRunning = false
    @State private var isTracking = false
    @State private var isConnecting = false
    @State private var connectionError = false
    @State private var askForScanning = false
    @State private var showForgetAlert = false
    @State private var showSaveAlert = false
    @State private var currentSession: Session? = nil
    @State private var data: [String] = []
    let deviceUUID: String
    let deviceName: String

    var body: some View {
        if accountManager.isConnected == false {
            LoginView(accountManager: accountManager)
        } else if askForScanning {
            ScanningView(bluetoothManager: bluetoothManager, accountManager: accountManager)
        } else if isConnecting {
            ProgressView("Connecting to \(deviceName == "Unknown" ? deviceUUID : deviceName)")
                .padding()
        } else {
            VStack {
                if !connectionError {
                    if !isSessionRunning {
                        Text("\(deviceName) selected for tracking")
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
                        
                        ChartView()
                            .environmentObject(chartViewModel)
                            .padding()
                        
                        Text(bluetoothManager.lastData ?? "")
                        
                        ButtonView(action: {
                            showSaveAlert = true
                            isTracking = false
                        }, text: "Pause tracking", background: .red)
                        .alert(isPresented: $showSaveAlert) {
                            Alert(
                                title: Text("Paused"),
                                message: Text("Session paused do you want to save?"),
                                primaryButton: .default(Text("Save")) {
                                    stopTracking()
                                },
                                secondaryButton: .cancel() {
                                    isTracking = true
                                }
                            )
                        }
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
            .onReceive(bluetoothManager.$lastData) { newData in
                if let newData = newData {
                    appendData(data: newData)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading, content: {
                    DisconnectView(accountManager: accountManager)
                })
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
        isSessionRunning = true
        isTracking = true
        if currentSession == nil { // Create session only if not already started
            currentSession = Session(start_date: String(Date().timeIntervalSince1970))
        }
    }
    
    func stopTracking() {
        currentSession?.end_date = String(Date().timeIntervalSince1970)
        if !self.data.isEmpty {
            currentSession?.setDataArrayToJSONString(data: data)
        }
        bluetoothManager.disconnectFromPeripheral()
        isSessionRunning = false
        saveSession()
    }
    
    func saveSession() {
        if let session = currentSession {
            if session.data != nil {
                accountManager.addSession(session: session) { result in
                    print(result)
                }
            }
        }
        self.currentSession = nil // Reset session after save
    }
    
    func forgetAndScan() {
        bluetoothManager.forgetLastConnectedUUID()
        askForScanning = true
    }
    
    func appendData(data: String) {
        let components = data.components(separatedBy: ",")
        self.data.append(data)
        if components.count == 3,
           let x = Double(components[0]),
           let y = Double(components[1]),
           let z = Double(components[2]) {
            chartViewModel.appendData(dataPoint: AccelerometerData(value: x, axis: "X"))
            chartViewModel.appendData(dataPoint: AccelerometerData(value: y, axis: "Y"))
            chartViewModel.appendData(dataPoint: AccelerometerData(value: z, axis: "Z"))
        }
    }
}

struct TrackingView_Previews: PreviewProvider {
    static var previews: some View {
        TrackingView(bluetoothManager: BluetoothManager(), accountManager: BackendManager(), deviceUUID: "12345", deviceName: "MacBook")
    }
}
