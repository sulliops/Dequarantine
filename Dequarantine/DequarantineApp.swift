//
//  DequarantineApp.swift
//  Dequarantine
//
//  Created by Owen Sullivan on 2/12/24.
//

import SwiftUI

// Application entry point
@main
struct DequarantineApp: App {
    
    // Main window Scene
    var body: some Scene {
        
        // Main WindowGroup
        WindowGroup {
            
            ContentView()
            
        }
        
        // Set default window size (matches content size in ContentView)
        .defaultSize(width: 250, height: 250)
        // Set WindowResizability attribute to contentSize to disable window resizing
        .windowResizability(.contentSize)
        
    }
    
}
