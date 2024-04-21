//
//  ChartView.swift
//  st-ios
//
//  Created by Raphaël Tournafond on 20/04/2024.
//

import SwiftUI
import Charts

struct AccelerometerData: Identifiable {
    let timestamp = Date()
    let value: Double
    let axis: String
    let id = UUID()
}

class ChartViewModel: ObservableObject {
    @Published var data: [AccelerometerData] = []
    let maxDataHistory = 20
    var buffer: [AccelerometerData] = []
    
    func generateRandomData() {
        let randomX = Double.random(in: -10.0...10.0)
        let randomY = Double.random(in: -10.0...10.0)
        let randomZ = Double.random(in: -10.0...10.0)
        appendData(dataPoint: AccelerometerData(value: randomX, axis: "X"))
        appendData(dataPoint: AccelerometerData(value: randomY, axis: "Y"))
        appendData(dataPoint: AccelerometerData(value: randomZ, axis: "Z"))
    }
    
    func appendData(dataPoint: AccelerometerData) {
        DispatchQueue.main.async {
            withAnimation(.easeOut(duration: 0.1)) {
                self.buffer.append(dataPoint)
                if self.buffer.count >= 3 {
                    self.data.append(contentsOf: self.buffer)
                    self.buffer.removeAll()
                }
                if self.data.count > self.maxDataHistory * 3 {
                    self.data.removeFirst(3)
                }
            }
        }
    }
    
    func clearData() {
        data.removeAll()
    }
}

struct ChartView: View {
    @EnvironmentObject var chartViewModel: ChartViewModel
    let maxForce = 40
    
    var body: some View {
        VStack {
            Chart(chartViewModel.data.suffix(chartViewModel.maxDataHistory * 3)) {
                LineMark (
                    x: .value("Index", $0.timestamp),
                    y: .value("Value", $0.value)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(by: .value("Axis", $0.axis))
            }
            .chartYScale(domain: -maxForce...maxForce)
            .chartXAxis(.hidden)
            .padding()
        }
    }
}

struct ChartView_Previews: PreviewProvider {
    
    static var previews: some View {
        let chartViewModel = ChartViewModel()
        return VStack {
            ChartView()
                .environmentObject(chartViewModel)
            
            Button("Generate Random Data") {
                chartViewModel.generateRandomData()
            }
        }
    }
}

