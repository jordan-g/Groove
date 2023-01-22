//
//  EventsController.swift
//  Groove
//
//  Created by Jordan Guerguiev on 2023-01-22.
//

import Foundation
import Combine
import AppKit

extension Notification.Name {
    static let musicStateChanged = Notification.Name("music_state_changed")
    static let willTerminate = Notification.Name("will_terminate")
}

public class EventsController {
    init() {
        // Subscribe and post notification on Music state change
        DistributedNotificationCenter.default().addObserver(forName: NSNotification.Name("com.apple.Music.playerInfo"), object: nil, queue: nil) { notification in
            NotificationCenter.default.post(name: .musicStateChanged, object: notification)
        }
        
        // Subscribe and post notification on termination
        NotificationCenter.default.addObserver(forName: NSApplication.willTerminateNotification, object: nil, queue: .main) { notification in
            NotificationCenter.default.post(name: .willTerminate, object: notification)
        }
    }
}
