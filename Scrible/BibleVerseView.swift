//
//  BibleVerseView.swift
//  Scrible
//
//  Created by Jadon Gearhart on 9/25/24.
//

import SwiftUI

struct BibleVerseView: View {
    var refer: BibleReference
       var animation: Namespace.ID
    @State private var verse: String = ""
    var body: some View {
        VStack {
            Text(refer.fullReference)
                .font(.title3)
                .fontWeight(.bold)
                .navigationTransition(.zoom(sourceID: refer.id, in: animation))
            GroupBox {
                Text(verse)
                    .font(.title2)
                    
            }.frame(width: 400, height: 400)
            
                
            
        }.task {
            getVerse(refer.fullReference) { versee in
                verse = versee
                
            }
        }
    }
}


