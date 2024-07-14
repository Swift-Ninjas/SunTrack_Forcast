//
//  WeatherData.swift
//  SunTrack Forcast
//
//  Created by Marcel Jäger on 14.07.24.
//

import Foundation
import OpenMeteoSdk

struct WeatherData {
    let hourly: Hourly
    let daily: Daily

    struct Hourly {
        let time: [Date]
        let temperature2m: [Float]
    }
    struct Daily {
        let time: [Date]
        let temperature2mMax: [Float]
        let temperature2mMin: [Float]
        let daylightDuration: [Float]
    }
}
