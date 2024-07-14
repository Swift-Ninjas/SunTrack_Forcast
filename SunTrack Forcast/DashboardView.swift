//
//  DashboardView.swift
//  SunTrack Forcast
//
//  Created by Wilhelm Engeland on 14.07.24.
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Text("Montag")
                    LineChartView(data: [0, 0, 0, 0, 0, 0, 20, 22, 24, 27, 30, 30, 32, 30, 27, 24, 22, 24, 22, 23, 20, 0, 0, 0])
                        .frame(height: 300)
                        .padding(.horizontal, 0)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    
                    WeatherForecastView()
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("SunTrack")
                .navigationBarItems(trailing: Button(action: {
                }) {
                    Image(systemName: "gearshape")
                        .imageScale(.large)
                })
            }
        }
    }
}

struct WeatherForecastView: View {
    var body: some View {
        VStack {
            HStack(spacing: 20) {
                WeatherDayView(day: "Mo.", imageName: "cloud.heavyrain", kilowatt: "47,5 kw")
                WeatherDayView(day: "Di.", imageName: "sun.max", kilowatt: "98,5 kw")
                WeatherDayView(day: "Mi.", imageName: "sun.max", kilowatt: "89,0 kw")
            }
            .padding()
            
            HStack(spacing: 20) {
                WeatherDayView(day: "Do.", imageName: "cloud.heavyrain", kilowatt: "47,5 kw")
                WeatherDayView(day: "Fr.", imageName: "sun.max", kilowatt: "98,5 kw")
                WeatherDayView(day: "Sa.", imageName: "sun.max", kilowatt: "89,0 kw")
            }
            .padding()
            
            HStack(spacing: 20) {
                WeatherDayView(day: "So.", imageName: "cloud.heavyrain", kilowatt: "47,5 kw")
                Spacer()
                Spacer()
            }
            .padding()
        }
    }
}

struct WeatherDayView: View {
    let day: String
    let imageName: String
    let kilowatt: String
    
    var body: some View {
        VStack {
            Text(day)
                .font(.headline)
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 40)
            Text(kilowatt)
                .font(.title)
        }
        .frame(width: 60)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
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
                                    
                                    let stepWidth = fullWidth / 23
                                    
                                    let startPoint = CGPoint(x: 0, y: height - CGFloat(data[0]) * stepHeight)
                                    path.move(to: startPoint)
                                    
                                    for hour in 1..<24 {
                                        let x = CGFloat(hour) * stepWidth
                                        let y = height - CGFloat(data[hour]) * stepHeight
                                        path.addLine(to: CGPoint(x: x, y: y))
                                    }
                                },
                                with: .color(.blue),
                                lineWidth: 2
                            )
                        }
                        .frame(width: fullWidth, height: height - 30)
                        .background(Color.white.shadow(radius: 10))
                        
                        HStack(spacing: 0) {
                            ForEach(0..<24) { hour in
                                let stepWidth = fullWidth / 23
                                Text("\(hour):00")
                                    .font(.caption)
                                    .frame(width: stepWidth, alignment: .center)
                            }
                        }
                        .padding(.horizontal, 0)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 0)
                .border(Color.gray, width: 1)
                .cornerRadius(10)
                .shadow(radius: 5)
            }
            .padding(.horizontal, 0)
        }
        .padding(.horizontal, 0)
    }
}

#Preview {
    DashboardView()
}
