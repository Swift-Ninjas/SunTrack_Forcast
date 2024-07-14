//
//  ContentView.swift
//  SunTrack Forcast
//
//  Created by Nico Raecke on 14.07.24.
//

import SwiftUI

@Observable class ViewModel {
    
}

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
