//
//  DayResultData.swift
//  SunTrack Forcast
//
//  Created by Marcel Jäger on 14.07.24.
//

import Foundation

struct DayResultData {
    let date: Date
    var sunshineInterval: Float
    var minTemperature: Float
    var maxTemperature: Float
    let weatherCode: Float
    
    var averageTemperature: Float {
        (minTemperature + maxTemperature) / 2
    }
}
