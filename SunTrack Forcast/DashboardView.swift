//
//  DashboardView.swift
//  SunTrack Forcast
//
//  Created by Wilhelm Engeland on 14.07.24.
//

import SwiftUI

struct DashboardView: View {
    
    let model: ViewModel
    
    var body: some View {
        let _ = Self._printChanges()
        NavigationView {
            VStack(spacing: 25) {
                if model.isLoadingChartData {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .frame(height: 300)
                }else if model.currentChartData.count <= 1 {
                    ContentUnavailableView("Keine Daten", systemImage: "exclamationmark.triangle")
                } else {
                    KWHForecastChart(chartData: model.currentChartData)
                        .padding()
                        .background(.background)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    
//                        LineChartView(data: model.currentChartData.map { $0.kWh })
//                            .frame(height: 300)
//                            .padding(.horizontal, 0)
//                            .background(.background)
//                            .cornerRadius(10)
//                            .shadow(radius: 5)
                    
                    WeatherForecastView(chartData: model.currentChartData)
                        .padding()
                        .background(.background)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }

                UserValuesView(userPLZ: model.userPLZ, userkWH: model.userkWH)
                    .padding()
                    .background(.background)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                
                Spacer()
                
                Text("Letzte Aktualisierung: \(model.lastUpdate.formatted(date: .numeric, time: .standard))")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .navigationTitle("Solar Vorhersage")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        Task {
                            await update()
                        }
                    } label: {
                        Image(systemName: "arrow.circlepath")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
        .task {
           await update()
        }
    }
    
    private func update() async {
        model.fetchCoordinate()
        if let currentCoordinate = model.currentCoordinate {
            model.isLoadingChartData = true
            let resultData = await model.loadData(coordinate: currentCoordinate, daysForecast: 7)
            await model.calculateKWhChartData(from: resultData)
            model.isLoadingChartData = false
        }
    }
}

struct LineChartView: View {
    var data: [Double]
    
    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let stepHeight = height / 50
            let fullWidth = geometry.size.width * 3
            
            HStack(alignment: .top) {
                VStack(alignment: .trailing) {
                    ForEach((0...50).reversed(), id: \.self) { value in
                        if value % 10 == 0 {
                            Text("\(value)")
                                .font(.caption)
                                .frame(width: 30, height: stepHeight)
                        } else {
                            Spacer().frame(height: stepHeight)
                        }
                    }
                }
                .padding(.top, 10)
                
                ScrollView(.horizontal) {
                    VStack {
                        Canvas { context, size in
                            context.stroke(
                                Path { path in
                                    guard data.count == 24 else { return }
                                    
                                    let stepWidth = fullWidth / 24
                                    
                                    let startPoint = CGPoint(x: 0, y: height - CGFloat(data[0]) * stepHeight)
                                    path.move(to: startPoint)
                                    
                                    for hour in 1...24 {
                                        let x = CGFloat(hour) * stepWidth
                                        let y = height - CGFloat(data[hour % 24]) * stepHeight
                                        path.addLine(to: CGPoint(x: x, y: y))
                                    }
                                },
                                with: .color(.black),
                                lineWidth: 2
                            )
                        }
                        .frame(width: fullWidth, height: height - 50)
                        .background(.background)
                        .padding(.vertical, 15)
                        
                        HStack(spacing: 0) {
                            ForEach(0...24, id: \.self) { hour in
                                let stepWidth = fullWidth / 24
                                Text("\(hour):00")
                                    .font(.caption)
                                    .frame(width: stepWidth, alignment: .center)
                            }
                        }
                        .padding(.horizontal, 0)
                    }
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 0)
                .border(Color.clear, width: 0)
                .cornerRadius(10)
                .shadow(radius: 5)
            }
            .padding(.horizontal, 0)
        }
        .padding(.horizontal, 0)
    }
}

struct WeatherForecastView: View {
    let chartData: Array<ViewModel.KWhChartData>
    
    var body: some View {
        Grid(horizontalSpacing: 20, verticalSpacing: 5) {
            GridRow {
                ForEach(chartData.map { $0.day }, id: \.self) { data in
                    Text(data.formatted(.dateTime.weekday(.short)))
                        .font(.callout.bold())
                        .fontDesign(.monospaced)
                }
            }
            GridRow {
                ForEach(chartData.map{ $0.systemImage }, id: \.self) { data in
                    Image(systemName: data)
                        .symbolVariant(.fill)
                }
            }
            GridRow {
                ForEach(chartData.map { $0.kWh }, id: \.self) { data in
                    VStack {
                        Text("\(Int(data / 1000))")
                            .font(.caption)
                            .fontDesign(.monospaced)
                            .lineLimit(1)
                        Text("MWh")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

//struct WeatherDayView: View {
//    let chartData: ViewModel.KWhChartData
//    
//    var body: some View {
//        VStack(spacing: 5){
//            Text(chartData.day.formatted(.dateTime.weekday(.short)))
//                .font(.callout.bold())
//                .fontDesign(.monospaced)
//            
//            Image(systemName: chartData.systemImage)
//                .symbolVariant(.fill)
//            
//            Text("\(Int(chartData.kWh / 1000))")
//                .font(.headline)
//                .fontDesign(.monospaced)
//                .lineLimit(1)
//            Text("MWh")
//                .font(.caption2)
//                .foregroundStyle(.secondary)
//        }
//        .padding(5)
//        .background(.background)
//        .cornerRadius(10)
//    }
//}

struct UserValuesView: View {
    let userPLZ: String
    let userkWH: Double?
    
    var body: some View {
        HStack {
            
            Spacer()
            
            VStack {
                Text("PLZ")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text(userPLZ)
                    .font(.subheadline)
            }
            
            Spacer()
            
            VStack {
                Text("kWh der Anlage")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text((userkWH ?? 0.0).formatted() + " kWh")
                    .font(.subheadline)
            }
            
            Spacer()
        }
    }
}

//struct SetTextfielView: View {
//    @Bindable var model: ViewModel
//    
//    var body: some View {
//        VStack(spacing: 10) {
//            Text("PLZ \(model.userPLZ)")
//            Text("\((model.userkWH ?? 0.0).formatted() ) kWh")
//        }
//        .padding()
//    }
//}


#Preview {
    DashboardView(model: ViewModel())
}
