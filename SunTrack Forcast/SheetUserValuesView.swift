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

    @State var plzInputValue: String
    @State var kWhInputValue: Double?
    @State var plzErrorMsg: String = ""
    @State var kWhErrorMsg: String = ""
    
    
    @Environment(\.dismiss) var dismissAction
    
    var body: some View {
        Form{
            Section(header: Text("Postleitzahl ändern:"), footer: Text(plzErrorMsg).foregroundColor(.red)){
                TextField("Postleitzahl", text: $plzInputValue)
            }
            Section(header: Text("kWh der Anlage ändern:"), footer: Text(kWhErrorMsg).foregroundColor(.red)){
                TextField("kWh der Anlage", value: $kWhInputValue, format: .number)
            }
            
            Button {
                if(plzInputValue != "" && kWhInputValue != nil){
                    plzErrorMsg = ""
                    kWhErrorMsg = ""
                    model.saveUserValues(plz: plzInputValue, kWh: kWhInputValue)
                    dismissAction.callAsFunction()
                }else{
                    if(kWhInputValue == nil && plzInputValue == ""){
                        plzErrorMsg = "Gib bitte eine Postleitzahl ein!"
                        kWhErrorMsg = "Gib bitte die kWh der Anlage ein!"
                    }else if( kWhInputValue != nil ){
                        plzErrorMsg = "Gib bitte eine Postleitzahl ein!"
                        kWhErrorMsg = ""
                    }else{
                        kWhErrorMsg = "Gib bitte die kWh der Anlage ein!"
                        plzErrorMsg = ""
                    }
                }
            } label: {
                Text("Speichern")
            }
        }
        
    }
}
