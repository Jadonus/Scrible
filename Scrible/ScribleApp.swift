//
//  ScribleApp.swift
//  Scrible
//
//  Created by Jadon Gearhart on 5/17/24.
//

import SwiftUI
import SwiftData
import TipKit
@main
struct ScribleApp: App {
    let container: ModelContainer

    @AppStorage("splitScreen") private var splitScreen = false
    @ObservedObject var navigationManager = NavigationManager.shared
    //@Query var saved: [ScribleSaves]
    @State private var navPath = NavigationPath()
    @State private var selection: Selection? = .bible
    @AppStorage("page") var page = 1
    //@Query var highlights: [ScribleHighlights]
    init() {
        do {
            container = try ModelContainer(for: ScribleSaves.self, ScribleHighlights.self, NoteSaves.self)
        } catch {
            fatalError("Failed to create ModelContainer for Movie.")
        }
    }

    @State private var tabSelection: Selection = .bible
    @State private var verseReference = "John 3:16"
    @State private var showOnboarding = true
    var body: some Scene {
        WindowGroup {
            VStack {
                
                //Blue rectangle
                
                    
            }
            TabView(selection: $tabSelection) {
                Tab("Bible", systemImage: "book.fill", value: .bible) {
                    BibleHomeView(verseReference: $verseReference).sheet(isPresented: $showOnboarding) {
                        Onboardingg()
                    }              }
                Tab("Highlights", systemImage: "highlighter", value: .saved) {
                    HighlightsView()
                       // List(highlights) { highlight in
                         //   Text("\(highlight.verseText) \(highlight.reference)")
                        //}.navigationTitle("Saved")
                    }
                Tab("Notes", systemImage: "pencil.and.scribble", value: .notes) {
                    Notes(modelContext: container.mainContext, page: page, verseReference: $verseReference, tabSelection: $tabSelection).navigationTitle("Notes")
                    }
                Tab("Settings", systemImage: "gear", value: .settings) {
                        Settings()
                    }
                
                
            }.tabViewStyle(.sidebarAdaptable)
                .task {
                // Configure and load your tips at app launch.
                do {
                    try Tips.configure()
                }
                catch {
                    // Handle TipKit errors
                    print("Error initializing TipKit \(error.localizedDescription)")
                }
            }
        }.modelContainer(container)
        
        
    }
}

struct HighlightsView: View {
    @Environment(\.modelContext) var modelContext
    @Query var saved: [ScribleSaves]
    var body: some View {
        List {
            ForEach(saved) { saved in
                VStack {
                    Image(uiImage: getstupidimage(data: saved.drawing))
                    Text(saved.chapter)
                }
                
            }
        }
    }
}
