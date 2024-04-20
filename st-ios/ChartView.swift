//
//  ChartView.swift
//  st-ios
//
//  Created by Raphaël Tournafond on 20/04/2024.
//

import SwiftUI
import Charts

struct AccelerometerData {
    let x: Double
    let y: Double
    let z: Double
    let id = UUID()
}

class ChartViewModel: ObservableObject {
    @Published var data: [AccelerometerData] = []
    
    func generateRandomData() {
        let randomX = Double.random(in: -1.0...1.0)
        let randomY = Double.random(in: -1.0...1.0)
        let randomZ = Double.random(in: -1.0...1.0)
        let newData = AccelerometerData(x: randomX, y: randomY, z: randomZ)
        appendData(dataPoint: newData)
    }
    
    private func appendData(dataPoint: AccelerometerData) {
        data.append(dataPoint)
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
            Chart(Array(chartViewModel.data.suffix(10).enumerated()), id: \.0) { index, dataPoint in
                LineMark (
                    x: .value("Index", String(index)),
                    y: .value("X", dataPoint.x)
                )
                .interpolationMethod(.catmullRom)
            }
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

