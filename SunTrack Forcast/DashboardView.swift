//
//  DashboardView.swift
//  SunTrack Forcast
//
//  Created by Wilhelm Engeland on 14.07.24.
//

import SwiftUI

    struct DashboardView: View {
        
        let model: ViewModel
        
        @State var kwHourArray: [Double] = [0, 0, 0, 0, 0, 0, 20.3, 22, 24, 27, 30, 30, 32, 30, 27, 24, 22, 24, 22, 23, 20, 0, 0, 0]
        @State var selectedDay: String = "Montag"
        @State var nextDayArray: [String] = ["Mo.", "Di.", "Mi.", "Do.", "Fr.", "Sa.", "So."]
        @State var calculateDayKwArray: [Double] = [47.5, 66.9, 66.8, 78.8, 47.7, 88.8, 67,7]
        
        var body: some View {
            NavigationView {
                ScrollView {
                    VStack {
                        Text(selectedDay)
                        LineChartView(data: kwHourArray)
                            .frame(height: 300)
                            .padding(.horizontal, 0)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        
                        WeatherForecastView(nextDayArray: $nextDayArray, calculateDayKwArray: $calculateDayKwArray)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                        
                        SetTextfielView(model: model)
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
                            .background(Color.white.shadow(radius: 10))
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
        @Binding var nextDayArray: [String]
        @Binding var calculateDayKwArray: [Double]
        
        var body: some View {
            VStack {
                HStack(spacing: 20) {
                    WeatherDayView(day: nextDayArray[0], imageName: "cloud.heavyrain", kilowatt: String(calculateDayKwArray[0]))
                    WeatherDayView(day: nextDayArray[1], imageName: "sun.max", kilowatt: String(calculateDayKwArray[1]))
                    WeatherDayView(day: nextDayArray[2], imageName: "sun.max", kilowatt: String(calculateDayKwArray[2]))
                    WeatherDayView(day: nextDayArray[3], imageName: "cloud.heavyrain", kilowatt: String(calculateDayKwArray[3]))
                }
                .padding()
                
                HStack(spacing: 20) {
                    WeatherDayView(day: nextDayArray[4], imageName: "sun.max", kilowatt: String(calculateDayKwArray[4]))
                    WeatherDayView(day: nextDayArray[5], imageName: "sun.max", kilowatt: String(calculateDayKwArray[5]))
                    WeatherDayView(day: nextDayArray[6], imageName: "cloud.heavyrain", kilowatt: String(calculateDayKwArray[6]))
                }
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
                    .frame(height: 20)
                Text(kilowatt)
                Text("kW")
            }
            .frame(width: 60)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
    }

    struct SetTextfielView: View {
        @Bindable var model: ViewModel
        
        var body: some View {
            VStack(spacing: 10) {
                Text(model.userPLZ)
                Text(String(model.userkWH!))
            }
            .padding()
        }
    }


    #Preview {
        DashboardView(model: ViewModel())
    }
