//
//  DayResultData.swift
//  SunTrack Forcast
//
//  Created by Marcel Jäger on 14.07.24.
//

import Foundation

struct DayResultData {
    var daylightInterval: Float
    var minTemperature: Float
    var maxTemperature: Float
    
    var averageTemperature: Float {
        (minTemperature + maxTemperature) / 2
    }
}
