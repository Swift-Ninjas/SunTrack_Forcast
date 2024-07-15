//
//  EntryUserValuesView.swift
//  SunTrack Forcast
//
//  Created by Marcel Jäger on 14.07.24.
//

import Foundation
import SwiftUI

struct EntryUserValuesView: View {
    let model: ViewModel
    
    @State var plzInputValue: String = ""
    @State var kWhInputValue: Double? = nil
    
    var body: some View {
        VStack {
            Group {
                TextField("PLZ", text: $plzInputValue)
                    .textContentType(.postalCode)
                    
                TextField("kWh der Anlage", value: $kWhInputValue, format: .number)
            }
            .textFieldStyle(.roundedBorder)
            .font(.title3)
            
            Button {
                model.saveUserValues(plz: plzInputValue, kWh: kWhInputValue)
                model.fetchCoordinate()
            } label: {
                Text("LOS!")
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .controlSize(.extraLarge)
            .padding(.vertical)
        }
        .padding()
    }
}


#Preview {
    EntryUserValuesView(model: .init())
}
