//
//  ContentView.swift
//  SunTrack Forcast
//
//  Created by Nico Raecke on 14.07.24.
//

import SwiftUI

struct ContentView: View {
    @State var model = ViewModel()
    
    var body: some View {
        if true {   //Wenn Userdaten leer sind.
            EntryUserValuesView(model: model)
        }else {
            //DaschboardView
        }
    }
}

#Preview {
    ContentView()
}
