//
//  ContentView.swift
//  Groove
//
//  Created by Jordan Guerguiev on 2023-01-21.
//

import SwiftUI
import MediaPlayer
import ScriptingBridge
import NotificationCenter

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
