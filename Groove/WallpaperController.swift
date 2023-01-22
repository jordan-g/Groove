//
//  WallpaperController.swift
//  Groove
//
//  Created by Jordan Guerguiev on 2023-01-22.
//

import Foundation
import ScriptingBridge
import NotificationCenter

extension NSImage {
    var pngData: Data? {
        guard let tiffRepresentation = tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmapImage.representation(using: .png, properties: [:])
    }
    func pngWrite(to url: URL, options: Data.WritingOptions = .atomic) -> Bool {
        do {
            try pngData?.write(to: url, options: options)
            return true
        } catch {
            print(error)
            return false
        }
    }
}

public class WallpaperController {
    var initialWallpaperURL: URL?
    
    init() {
        // Subscribe to Music state change notifications
        NotificationCenter.default.addObserver(forName: .musicStateChanged, object: nil, queue: .main) { notification in
            self.updateWallpaper()
        }
        
        // Subscribe to termination notification
        NotificationCenter.default.addObserver(forName: .willTerminate, object: nil, queue: .main) { notification in
            self.setInitialWallpaper()
        }
        
        // Get current wallpaper URL and store it
        self.getInitialWallpaperURL()
        
        // Do an initial update
        self.updateWallpaper()
    }
    
    func getInitialWallpaperURL() {
        do {
            let workspace = NSWorkspace.shared
            if let screen = NSScreen.main  {
                self.initialWallpaperURL = workspace.desktopImageURL(for: screen)
            }
        }
    }
    
    func setInitialWallpaper() {
        if let url = self.initialWallpaperURL {
            self.setWallpaper(url: url)
        }
    }
    
    func updateWallpaper() {
        if let app: MusicApplication = SBApplication(bundleIdentifier: "com.apple.Music"),
           let currentTrack = app.currentTrack,
           let artworks = currentTrack.artworks {
            if artworks().count > 0 {
                if let artwork = artworks()[0] as? MusicArtwork {
                    // Get artwork NSImage
                    var artworkImage: NSImage?
                    // TODO: Add a timeout
                    while (artworkImage == nil) {
                        artworkImage = artwork.data
                    }
                    
                    if let artworkImage {
                        // Set wallpaper
                        self.setWallpaper(artwork: artworkImage)
                    }
                }
            }
        }
    }
    
    func setWallpaper(artwork: NSImage) {
        if let blurredArtwork = self.blurImage(image: artwork) {
            // Save to temporary URL
            let uuid = UUID().uuidString
            let url: URL = URL(fileURLWithPath: "\(uuid).png")
            
            let success = blurredArtwork.pngWrite(to: url, options: Data.WritingOptions.atomic)
            
            if success {
                // Set wallpaper
                self.setWallpaper(url: url)
            }
        }
    }
    
    func setWallpaper(url: URL) {
        do {
            let workspace = NSWorkspace.shared
            if let screen = NSScreen.main  {
                try workspace.setDesktopImageURL(url, for: screen, options: [:])
            }
        } catch {
            print(error)
        }
    }
    
    func blurImage(image: NSImage) -> NSImage? {
        if let tiffRepresentation = image.tiffRepresentation {
            let inputImage = CIImage(data: tiffRepresentation)
            if let filter = CIFilter(name: "CIGaussianBlur") {
                filter.setDefaults()
                filter.setValue(inputImage, forKey: kCIInputImageKey)
                
                if let outputImage = filter.value(forKey: kCIOutputImageKey) as? CIImage {
                    let outputImageRect = NSRectFromCGRect(outputImage.extent)
                    let blurredImage = NSImage(size: outputImageRect.size)
                    blurredImage.lockFocus()
                    outputImage.draw(at: NSZeroPoint, from: outputImageRect, operation: NSCompositingOperation.copy, fraction: 1.0)
                    blurredImage.unlockFocus()
                    
                    return blurredImage
                }
            }
        }
        
        return nil
    }
}
