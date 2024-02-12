//
//  ContentView.swift
//  Dequarantine
//
//  Created by Owen Sullivan on 2/12/24.
//

import SwiftUI
import XAttr

// Custom ButtonStyle that includes a scale effect
struct CustomScaleEffectButtonStyle : ButtonStyle {
    
    func makeBody(configuration: Self.Configuration) -> some View {
        
        configuration.label
            // Scale the button down slightly when pressed
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
        
    }
    
}

// Main ContentView
struct ContentView: View {
    
    // Tracking variables for error alerts
    @State private var showConformingTypeIdentifierErrorAlert = false
    @State private var showFileImporterErrorAlert = false
    @State private var fileImporterErrorAlertMessage = ""
    @State private var showDequarantineErrorAlert = false
    @State private var dequarantineErrorAlertMessage = ""
    
    // Tracking variable for onDrop isTargeted
    @State private var onDropIsTargeted = false
    // Tracking variable for fileImporter
    @State private var importingFiles = false
    
    // Function that performs the file dequarantine operation
    func dequarantine(filePath: String) {
        
        // Create a URL object from the file path
        let fileURL = URL(fileURLWithPath: filePath)
        
        do {
            
            // If the file has the quarantine attribute, try to remove it
            if (try fileURL.extendedAttributeNames().contains("com.apple.quarantine")) {
                
                try fileURL.removeExtendedAttribute(forName: "com.apple.quarantine")
                
            }
            
        // Catch error and update alert tracking vars
        } catch let error {
            
            dequarantineErrorAlertMessage = error.localizedDescription
            showDequarantineErrorAlert = true
            
        }
        
    }
    
    // Body View
    var body: some View {
        
        // Main VStack
        VStack {
            
            // App title/usage text
            Text("Dequarantine")
                .bold()
                .padding(.bottom, 5)
            Text("Drag quarantined files onto this window or click inside the box below to browse...")
                .multilineTextAlignment(.center)
            
            // Add a horizontal divider with some padding
            Divider()
                .padding()
            
            // Create a top-level button to make click actions easier
            Button {
                
                // Update tracking var
                importingFiles = true
                
            } label: {
                
                // Dashed rectangle for outer border
                Image(systemName: "rectangle.dashed")
                
                    // Make image fit the window
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                    // Modify icon color
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.blue)
                
                    // Make it thinner
                    .font(Font.title.weight(.ultraLight))
                
                    // Make it partially transparent
                    .opacity(0.5)
                
                    // Image overlay (image inside dashed rectangle)
                    .overlay(
                        
                        // GeometryReader to work with size of parent image
                        GeometryReader { parent in
                            
                            // File icon
                            Image(systemName: "doc")
                            
                                // Make image fit the window
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                            
                                // Scale image size based on parent image's size
                                .frame(width: parent.size.width * 0.25, height: parent.size.height * 0.25)
                                .frame(width: parent.size.width, height: parent.size.height)
                            
                                // Modify icon color
                                .symbolRenderingMode(.palette)
                                .foregroundColor(.blue)
                            
                                // Make it partially transparent
                                .opacity(0.5)
                            
                        }
                        
                    )
                
                    // Transparent overlay that appears if onDrop is being targeted
                    .overlay(onDropIsTargeted ?
                             RoundedRectangle(cornerRadius: 15)
                                .fill(Color.gray.opacity(0.5))
                                .contentShape(RoundedRectangle(cornerRadius: 15))
                             : nil)
                    // Ease-in-out animation
                    .animation(.easeInOut(duration: 0.5), value: onDropIsTargeted)

            }
            
            // Enable custom scale effect with custom ButtonStyle
            .buttonStyle(CustomScaleEffectButtonStyle())
            // Set button style to borderless so that images show properly
            .buttonStyle(.borderless)
            
            // File picker on button click (monitors importingFiles tracker) that supports all item types and allows multiple selection
            .fileImporter(isPresented: $importingFiles, allowedContentTypes: [.item], allowsMultipleSelection: true) { result in
                
                switch (result) {
                    
                    // On success, dequarantine each file
                    case .success(let files):
                        for file in files {
                            
                            dequarantine(filePath: file.path)
                            
                        }
                    
                    // On failure, update error message and set tracking var
                    case .failure(let error):
                        fileImporterErrorAlertMessage = error.localizedDescription
                        showFileImporterErrorAlert = true
                    
                }
                
            }
            
        }
        
        // Extra padding
        .padding()
        
        // Set a fixed size for content
        .frame(width: 250, height: 250)
        .fixedSize()
        
        // onDrop action that accepts files for drag-and-drop operation
        .onDrop(of: ["public.file-url"], isTargeted: $onDropIsTargeted) { providers in
            
            // Loop through NSItemProvider objects
            for provider in providers {
                
                // Check that provider represents a valid file type
                if provider.hasItemConformingToTypeIdentifier("public.file-url") {
                    
                    // Load the file URL
                    _ = provider.loadObject(ofClass: URL.self) { fileURL, _ in
                        
                        // Unwrap the URL object
                        if let fileURL = fileURL {
                            
                            // Create a DispatchWorkItem that performs the dequarantine action on the file
                            let workItem = DispatchWorkItem() {
                                
                                dequarantine(filePath: fileURL.path)
                                
                            }
                            
                            // Tell the main thread to execute the DispatchWorkItem
                            DispatchQueue.main.async(execute: workItem)
                            
                        }
                        
                    }
                    
                // If not, trigger error alert (but continue, because there may still be files to recognize)
                } else {
                    
                    showConformingTypeIdentifierErrorAlert = true
                    
                }
                
            }
            
            return true
            
        }
        
        // Error alert for ConformingTypeIdentifier check
        .alert("Error: File(s) not identifiable", isPresented: $showConformingTypeIdentifierErrorAlert, actions: {}, message: {
            
            Text("One or more of the files you provided are unidentifiable and cannot have their paths parsed. Please try again with different files or contact the developer about this issue.")
            
        })
        // Error alert for fileImporter failure
        .alert("Error: Could not select file(s)", isPresented: $showFileImporterErrorAlert, actions: {}, message: {
            
            Text("One or more of the files you selected could not be imported. Please try again with different files or contact the developer about this issue.")
            Text("The following error text was generated: \(fileImporterErrorAlertMessage)")
            
        })
        // Error alert for dequarantine failure
        .alert("Error: Could not dequarantine file", isPresented: $showDequarantineErrorAlert, actions: {}, message: {
            
            Text("The dequarantine operation could not be performed. Please try again with a different file or contact the developer about this issue.")
            Text("The following error text was generated: \(dequarantineErrorAlertMessage)")
            
        })
        
    }
    
}

// Application preview
#Preview {
    
    ContentView()
    
}
