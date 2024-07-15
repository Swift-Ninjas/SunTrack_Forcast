//
//  KWHForecastChart.swift
//  SunTrack Forcast
//
//  Created by Marcel Jäger on 15.07.24.
//

import Foundation
import SwiftUI
import Charts

struct KWHForecastChart: View {
    let chartData: Array<ViewModel.KWhChartData>
    
    var body: some View {
        VStack {
            HStack {
                Text("Voraussichtliche Produktion in kWh")
                    .font(.headline)
                
                Spacer()
            }
            Chart(chartData, id: \.self) { data in
                BarMark(x: .value("Day", data.day, unit: .weekday), y: .value("kWh", data.kWh))
                    .foregroundStyle(.yellow.gradient)
                
            }
            .chartXAxis {
                AxisMarks(preset: .aligned, values: chartData.map { $0.day }) { value in
                    AxisValueLabel(format: .dateTime.weekday(), anchor: .topLeading)
                }
            }
        }
    }
}
