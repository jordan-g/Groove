//
//  GrooveApp.swift
//  Groove
//
//  Created by Jordan Guerguiev on 2023-01-21.
//

import SwiftUI

@main
struct GrooveApp: App {
    var eventsController: EventsController?
    var wallpaperController: WallpaperController?
    
    init() {
        eventsController = EventsController()
        wallpaperController = WallpaperController()
    }
    
    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
        
        MenuBarExtra("Groove", image: "groove.menubar") {
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }.keyboardShortcut("q")
        }
    }
}
