//
//  WeatherData.swift
//  SunTrack Forcast
//
//  Created by Marcel Jäger on 14.07.24.
//

import Foundation
import OpenMeteoSdk

struct WeatherData {
    let daily: Daily

    struct Daily {
        let time: [Date]
        let weatherCode: [Float]
        let temperature2mMax: [Float]
        let temperature2mMin: [Float]
        let sunshineDuration: [Float]
    }
}
