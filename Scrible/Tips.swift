//
//  Tips.swift
//  Scrible
//
//  Created by Jadon Gearhart on 11/6/24.
//


import SwiftUI
import TipKit


// Define your tip's content.
struct AddVerseInNotes: Tip {
    var title: Text {
        Text("Add Verse")
    }


    var message: Text? {
        Text("Double tap any where to add a verse to your notes")
    }


    var image: Image? {
        Image(systemName: "text.document.fill")
    }
}

