//
//  ViewModel.swift
//  SunTrack Forcast
//
//  Created by Marcel Jäger on 14.07.24.
//

import Foundation
import SwiftUI
import OpenMeteoSdk
import MapKit

@Observable class ViewModel {
    var userPLZ: String = ""
    var userkWH: Double? = nil  //Es ist ein Optional, damit das TextField den Promt anzeigt, wenn der User keinen Wert eingegeben hat.
    private let keyForUserPLZ = "USER_PLZ"
    private let keyForUserKWh = "USER_KWH"
   
    var currentCoordinate: CLLocationCoordinate2D? = nil
    var currentChartData: Array<KWhChartData> = []
    var isLoadingChartData: Bool = true
    
    var hasEnteredUserValues: Bool {
        (userPLZ.isEmpty == false) && (userkWH != nil)
    }
    
    init() {
        loadUserValues()
        fetchCoordinate()
    }
    
    func loadUserValues() {
        let userDefaults = UserDefaults.standard
        let savedUserPLZValue = userDefaults.string(forKey: keyForUserPLZ)
        let savedUserKWhValue = userDefaults.double(forKey: keyForUserKWh)
        userPLZ = savedUserPLZValue ?? ""
        userkWH = (savedUserKWhValue == 0.0) ? nil : savedUserKWhValue
    }
    
    func saveUserValues(plz: String, kWh: Double?) {
        self.userPLZ = plz
        self.userkWH = kWh
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(userPLZ, forKey: keyForUserPLZ)
        userDefaults.set(userkWH ?? 0.0, forKey: keyForUserKWh)
    }
}

extension ViewModel {
    private func getURL(coordinate: CLLocationCoordinate2D, daysForecast: Int) -> URL? {
        URL(string: "https://api.open-meteo.com/v1/forecast?latitude=\(coordinate.latitude)&longitude=\(coordinate.longitude)&daily=weather_code,temperature_2m_max,temperature_2m_min,sunshine_duration&timezone=Europe%2FLondon&forecast_days=7&format=flatbuffers")
//        URL(string: "https://api.open-meteo.com/v1/forecast?latitude=\(coordinate.latitude)&longitude=\(coordinate.longitude)&hourly=temperature_2m&daily=temperature_2m_max,temperature_2m_min,daylight_duration&timezone=Europe%2FLondon&forecast_days=\(daysForecast)&format=flatbuffers")
    }
    
    func fetchCoordinate() {
        if userPLZ.isEmpty {
            print("USER PLZ IS EMPTY")
            return
        }
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = userPLZ
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response else {
                print("ERROR")
                return
            }
            
            let coordinate = response.mapItems.map { $0.placemark.coordinate }.first
            self.currentCoordinate = coordinate
        }
    }
    
    func loadData(coordinate: CLLocationCoordinate2D, daysForecast: Int) async -> Array<DayResultData> {
        guard let url = getURL(coordinate: coordinate, daysForecast: daysForecast) else {
            return []
        }
        
        var response: Array<WeatherApiResponse>? = nil
        do {
            response = try await WeatherApiResponse.fetch(url: url)
        }catch {
            print(error)
        }
        
        guard let firstResponse = response?.first, let daily = firstResponse.daily else {
            return []
        }
        
        let utcOffsetSeconds = firstResponse.utcOffsetSeconds
        let timezone = firstResponse.timezone
        let timezoneAbbreviation = firstResponse.timezoneAbbreviation
        let latitude = firstResponse.latitude
        let longitude = firstResponse.longitude
        
        let data = WeatherData(
            daily: .init(
                time: daily.getDateTime(offset: utcOffsetSeconds),
                weatherCode: daily.variables(at: 0)!.values,
                temperature2mMax: daily.variables(at: 1)!.values,
                temperature2mMin: daily.variables(at: 2)!.values,
                sunshineDuration: daily.variables(at: 3)!.values
            )
        )
        
        var results: Array<DayResultData> = []
        for i in 0..<daysForecast {
            
            let date: Date? = if i > data.daily.time.count - 1 {
                nil
            }else {
                data.daily.time[i]
            }
            let sunshineIntervalOfDay: Float? = if i > data.daily.sunshineDuration.count - 1 {
                nil
            }else {
                data.daily.sunshineDuration[i]
            }
            
            let minTemperatureOfDay: Float? = if i > data.daily.temperature2mMin.count - 1 {
                nil
            }else {
                data.daily.temperature2mMin[i]
            }
            
            let maxTemperatureOfDay: Float? = if i > data.daily.temperature2mMax.count - 1 {
                nil
            }else {
                data.daily.temperature2mMax[i]
            }
            
            let weatherCodeOfDay: Float? = if i > data.daily.weatherCode.count - 1{
                nil
            } else {
                data.daily.weatherCode[i]
            }
            
            if let sunshineIntervalOfDay, let date, let minTemperatureOfDay, let maxTemperatureOfDay, let weatherCodeOfDay {
                results.append(DayResultData(date: date, sunshineInterval: sunshineIntervalOfDay, minTemperature: minTemperatureOfDay, maxTemperature: maxTemperatureOfDay, weatherCode: weatherCodeOfDay))
            }
            
        }
        
        return results
    }
}



extension ViewModel {
    struct KWhChartData: Hashable {
        var kWh: Double
        var day: Date
        var weatherCode: Float
        
        var systemImage: String {
            switch weatherCode {
            case 0:
                "sun.max"
            case 1...2:
                "cloud.sun"
            case 3:
                "cloud"
            case 45...48:
                "cloud.fog"
            case 51...55:
                "cloud.drizzle"
            case 56...57:
                "cloud.sleet"
            case 61...65:
                "cloud.rain"
            case 66...67:
                "cloud.sleet"
            case 71...75:
                "cloud.snow"
            case 77:
                "cloud.hail"
            case 80...82:
                "cloud.sun.rain"
            case 85...86:
                "cloud.snow"
            case 95:
                "cloud.bolt"
            case 96...99:
                "cloud.bolt.rain"
            default:
                "sun.min"
            }
        }
    }
    
    func calculateKWhChartData(from dayResults: Array<DayResultData>) async {
        let kWhOfPowerPlant = userkWH
        
        guard let kWhOfPowerPlant else {
            return
        }
        
        var chartData: Array<KWhChartData> = []
        
        for dayResult in dayResults {
            let averageTemp = dayResult.averageTemperature
            var productionDecreaseInPercent = 0.0
            
            if averageTemp > 25 {
                productionDecreaseInPercent = Double((averageTemp - 25) * 0.5)
            }
            
            var kWhSum = (Double(dayResult.sunshineInterval) / 60 / 60) * kWhOfPowerPlant * productionDecreaseInPercent
            
            chartData.append(KWhChartData(kWh: kWhSum, day: dayResult.date, weatherCode: dayResult.weatherCode))
        }
        
        self.currentChartData = chartData
    }
}



extension CLLocationCoordinate2D: Hashable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == lhs.longitude
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.latitude)
        hasher.combine(self.longitude)
    } 
}
