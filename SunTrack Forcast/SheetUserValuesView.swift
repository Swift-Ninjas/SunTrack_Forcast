//
//  SheetUserValuesView.swift
//  SunTrack Forcast
//
//  Created by Nico Raecke on 14.07.24.
//

import Foundation
import SwiftUI



struct SheetUserValuesView: View {

    let model: ViewModel

    @State var plzInputValue: String = ""
    @State var kWhInputValue: Double? = nil
    
    @Environment(\.dismiss) var dismissAction
    
    var body: some View {
        Form{
            Section{
                TextField("PLZ", text: $plzInputValue)
                TextField("kWh der Anlage", value: $kWhInputValue, format: .number)
            }
            
            Button {
                model.saveUserValues(plz: plzInputValue, kWh: kWhInputValue)
                dismissAction.callAsFunction()
            } label: {
                Text("Speichern")
            }
        }
        
    }
}
