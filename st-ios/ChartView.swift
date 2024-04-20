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
    let x: Double
    let y: Double
    let z: Double
    let id = UUID()
}

class ChartViewModel: ObservableObject {
    @Published var data: [AccelerometerData] = []
    let maxDataHistory = 20
    let movingAverage = 5
    
    func generateRandomData() {
        let randomX = Double.random(in: -10.0...10.0)
        let randomY = Double.random(in: -10.0...10.0)
        let randomZ = Double.random(in: -10.0...10.0)
        let newData = AccelerometerData(x: randomX, y: randomY, z: randomZ)
        appendData(dataPoint: newData)
    }
    
    func appendData(dataPoint: AccelerometerData) {
        withAnimation(.easeOut(duration: 0.1)) {data.append(dataPoint)}
        if (data.count > maxDataHistory) {
            data.removeFirst()
        }
    }
    
    func clearData() {
        data.removeAll()
    }
}

struct ChartView: View {
    @EnvironmentObject var chartViewModel: ChartViewModel
    let count: Int
    
    init(count: Int = 10) {
        self.count = count
    }
    
    var body: some View {
        VStack {
            Chart(chartViewModel.data.suffix(chartViewModel.maxDataHistory)) {
                LineMark (
                    x: .value("Index", $0.timestamp),
                    y: .value("X", $0.x)
                )
                .interpolationMethod(.catmullRom)
            }
            .chartYScale(domain: -20.0...20.0)
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

