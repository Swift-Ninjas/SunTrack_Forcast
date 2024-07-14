//
//  ViewModel.swift
//  SunTrack Forcast
//
//  Created by Marcel Jäger on 14.07.24.
//

import Foundation
import SwiftUI

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
