//
//  DB.swift
//  Scrible
//
//  Created by Jadon Gearhart on 5/17/24.
//
import PencilKit
import Foundation
import SwiftData
import SwiftUI
@Model
final class NoteSaves {
    #Unique<NoteSaves>([\.page])
    var date: Date
   var page: Int
    var drawing: Data
    var id: UUID
    var buttons: [NoteRef]
    init(date: Date, page: Int,  drawing: Data, id: UUID, buttons: [NoteRef]) {
        self.date = .now
        self.page = page
        self.drawing = drawing
        self.id = UUID()
        self.buttons = buttons
    }
}
@Model
final class ScribleSaves {
    //#Unique<ScribleSaves>([\.chapter])
    var date: Date
    @Attribute(.unique) var chapter: String
    var id: UUID
    var drawing: Data
    init(date: Date, chapter: String, id: UUID, drawing: Data) {
        self.date = .now
        self.chapter = chapter
        self.id = id
        self.drawing = drawing
    }
}
@Model
final class ScribleHighlights {
    #Unique<ScribleHighlights>([\.reference])
    var date: Date
    var reference: String
    var id: UUID
    var verseText: String // New property with default value
    
    var color: HighlightColor
    init(date: Date, reference: String, id: UUID,verseText: String = "", color: HighlightColor) {
        self.date = .now
        self.reference = reference
        self.id = id
        self.verseText = verseText
        self.color = color
    }
}


enum HighlightColor: String,Codable, CaseIterable {
        case pink, orange, yellow, blue, purple
    var color: Color {
            switch self {
            case .pink:
                return Color.pink
            case .orange:
                return Color.orange
            case .yellow:
                return Color.yellow
            case .blue:
                return Color.blue
            case .purple:
                return Color.purple
            }
        }
    

}


