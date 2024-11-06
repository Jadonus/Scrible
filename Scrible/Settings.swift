//
//  Settings.swift
//  Scrible
//
//  Created by Jadon Gearhart on 5/20/24.
//

import SwiftUI
import SwiftData
struct SettingsLabel<Content>: View where Content: View {
    var label: String
    var image: String
    var color: Color
    var content: () -> Content

    var body: some View {
        HStack(spacing: 10) { // Adjust spacing as needed
            ZStack {
             RoundedRectangle(cornerRadius: 8)
                    .fill(color)
                    .frame(width: 35, height: 35) // Fixed size for the background

                Image(systemName: image)
                    .foregroundColor(.white)
                    .font(.system(size: 15)) // Adjust font size as needed
            }

            Text(label)
            content()
        }
    }
}


struct Settings: View {
    let imageTitles = ["AppiconDisplay", "colors"]
    let imageDisplayTitles = ["Default", "Colorful"]
    let appIconTitles = ["AppIcon", "color"]
@AppStorage("appicon") private var appicon = "default"
    @AppStorage("strongsLink") var strongsLink = "copy"
    @AppStorage("margin") private var margin = 200.0
    @AppStorage("splitScreen") private var splitScreen = false
    @AppStorage("font") private var font = "regular"
    @AppStorage("highlightColor") private var highlightColor: HighlightColor = .yellow
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Bible")) {
                    SettingsLabel(label: "Margin", image: "arrow.up.and.down.text.horizontal", color: .blue) {
                        
                        
                        Slider(value: $margin, in: 10...700, step: 40 )
                    }
                    
                    SettingsLabel(label: "Font", image: "textformat", color: .orange) {
                        
                        
                        
                        Picker("", selection: $font
                        
                        ) {
                            Text("Default").tag("regular").fontDesign(.default)
                            Text("Serif").tag("serif").fontDesign(.serif)
                            Text("Monospace").tag("monospaced").fontDesign(.monospaced)
                            Text("Rounded").tag("rounded").fontDesign(.rounded)
                        }.pickerStyle(.navigationLink)
                    }
                    SettingsLabel(label: "Strongs Number", image: "link", color: .cyan) {
                        Picker("", selection: $strongsLink) {
                            Label("Open in browser", systemImage: "globe").tag("browser")
                            Label("Copy to clipboard", systemImage: "doc.on.clipboard.fill").tag("copy")
                        }
                    }
                    SettingsLabel(label: "Text columns", image: "square.split.2x1.fill", color: .mint) {
                        Picker("", selection: $splitScreen) {
                            Label("1 Column", systemImage: "square.fill").tag(false)
                            Label("2 Column", systemImage: "quare.split.2x1.fill").tag(true)
                        }
                    }
                }.navigationTitle("Settings")
                Section(header: Text("Highlights")) {
                    SettingsLabel(label: "Highlight color", image: "highlighter", color: .green) {
                        Picker("", selection: $highlightColor) {
                            ForEach(HighlightColor.allCases, id: \.self) { highlightColor in
                                
                                Text(highlightColor.rawValue.capitalized).tag(highlightColor)
                                
                            }
                        }
                    }
                }
                Section(header: Text("Overall appearance")) {
                    #if(canImport(UIKit))
                    SettingsLabel(label: "App Icon", image: "app.badge.fill", color: .purple) {

                        
                        
                        Picker("", selection: $appicon) {
                            ForEach(imageTitles.indices, id:\.self) { index in
                                HStack {
                                    
                                    Image(imageTitles[index]).resizable().frame(width: 60, height: 60).clipShape(.rect(cornerRadius: 10))
                                    Text(imageDisplayTitles[index])
                                }.tag(appIconTitles[index])
                                
                            }
                        }.pickerStyle(.navigationLink)
                        
                    }
                    #endif
                }
            }
            
        }
    }
}

