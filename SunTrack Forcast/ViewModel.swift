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
    private let keyForUserPLZ = ""
    private let keyForUserKWh = ""
    
    var hasEnteredUserValues: Bool {
        (userPLZ.isEmpty == false) && (userkWH != nil)
    }
    
    init() {
        loadUserValues()
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
        URL(string: "https://api.open-meteo.com/v1/forecast?latitude=\(coordinate.latitude)&longitude=\(coordinate.longitude)&hourly=temperature_2m&daily=temperature_2m_max,temperature_2m_min,daylight_duration&timezone=Europe%2FLondon&forecast_days=\(daysForecast)&format=flatbuffers")
    }
    
    func fetchCoordinate(ofPLZ plz: String, completionHandler: @escaping (CLLocationCoordinate2D?) -> Void) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = plz
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response else {
                print("ERROR")
                completionHandler(nil)
                return
            }
            
            let coordinate = response.mapItems.map { $0.placemark.coordinate }.first
            completionHandler(coordinate)
        }
    }
    
    func loadData(coordinate: CLLocationCoordinate2D, daysForecast: Int) async -> Array<DayResultData> {
        guard let url = getURL(coordinate: coordinate, daysForecast: daysForecast) else {
            return []
        }
        
        let response = try? await WeatherApiResponse.fetch(url: url)
        
        guard let firstResponse = response?.first, let hourly = firstResponse.hourly, let daily = firstResponse.daily else {
            return []
        }
        
        let utcOffsetSeconds = firstResponse.utcOffsetSeconds
        let latitude = firstResponse.latitude
        let longitude = firstResponse.longitude
        
        let data = WeatherData(
            hourly: .init(
                time: hourly.getDateTime(offset: utcOffsetSeconds),
                temperature2m: hourly.variables(at: 0)!.values
            ),
            daily: .init(
                time: daily.getDateTime(offset: utcOffsetSeconds),
                temperature2mMax: daily.variables(at: 0)!.values,
                temperature2mMin: daily.variables(at: 1)!.values,
                daylightDuration: daily.variables(at: 2)!.values
            )
        )
        
        var results: Array<DayResultData> = []
        for i in 0..<daysForecast {
            
            let daylightIntervalOfDay: Float? = if data.daily.daylightDuration.count > i+1 {
                nil
            }else {
                data.daily.daylightDuration[i]
            }
            
            let minTemperatureOfDay: Float? = if data.daily.temperature2mMin.count > i+1 {
                nil
            }else {
                data.daily.temperature2mMin[i]
            }
            
            let maxTemperatureOfDay: Float? = if data.daily.temperature2mMax.count > i+1 {
                nil
            }else {
                data.daily.temperature2mMax[i]
            }
            
            if let daylightIntervalOfDay, let minTemperatureOfDay, let maxTemperatureOfDay {
                results.append(DayResultData(daylightInterval: daylightIntervalOfDay, minTemperature: minTemperatureOfDay, maxTemperature: maxTemperatureOfDay))
            }
            
        }
        return results
    }
}
