//
//  ScribleIntents.swift
//  ScribleIntents
//
//  Created by Jadon Gearhart on 7/16/24.
//

import AppIntents
import SwiftUI
struct ScribleIntents: AppIntent {
    static var title: LocalizedStringResource = "ScribleIntents"
    
    func perform() async throws -> some IntentResult {
        return .result()
    }
}
struct OpenBibleVerse: AppIntent {
    static var title: LocalizedStringResource = "Open Bible Verse"
    static var description = IntentDescription("Jumps you right into the app, and into your favourite coffee.")

    @Parameter(title: "Verse Reference")
    var verseReference: String?
    //static var openAppWhenRun: Bool = true
@MainActor
    func perform() async throws -> some IntentResult {
          // Instead of using UIApplication.shared, you can return a response that your app can handle
        return .result(value: verseReference, dialog: .init("Opening"))
    }
  }

