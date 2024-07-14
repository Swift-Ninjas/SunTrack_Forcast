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
    
    @State var dummyPLZ: String = ""
    @State var dummyKWh: Double? = nil
    
    var body: some View {
        VStack {
            Group {
                TextField("PLZ", text: $dummyPLZ)
                    .textContentType(.postalCode)
                    
                TextField("kWh der Anlage", value: $dummyKWh, format: .number)
            }
            .textFieldStyle(.roundedBorder)
            .font(.title3)
            
            Button {
                //ViewModel Methode
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
