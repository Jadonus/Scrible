//
//  ManualChooser.swift
//  Scrible
//
//  Created by Jadon Gearhart on 7/29/24.
//

import SwiftUI
import Combine
struct dgStyle: DisclosureGroupStyle {

  func makeBody(configuration: Configuration) -> some View {
      
      HStack {
          configuration.label
              .font(.title3)
              .foregroundColor(.white)
              .padding()

          Spacer()
          Button(action: {                     withAnimation {
              configuration.isExpanded.toggle()
          }
          }) {
              Image(systemName: "chevron.down" ).rotationEffect(!configuration.isExpanded ? .degrees(-90) : .zero).contentTransition(.opacity).font(.callout).bold()
          }.padding()
      }
      if configuration.isExpanded {
          configuration.content.transition(.swipeDelete)
      }
  }
}
class VerseViewModel: ObservableObject {
    @Published var verses: [Versees] = []
    @Published var books: [Int] = []
    @Published var chapters: [Int] = []
    @Published var versesInChapter: [Versees] = []
    @Published var verse: Int = 1
    @Published var selectedBook: Int? = nil
    @Published var selectedChapter: Int? = nil
    
    init() {
        loadVerses()
    }
    
    func loadVerses() {
        if let url = Bundle.main.url(forResource: "Bible", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let decodedVerses = try decoder.decode([Versees].self, from: data)
                self.verses = decodedVerses
                self.books = Array(Set(decodedVerses.map { $0.book })).sorted()
            } catch {
                print("Error decoding JSON: \(error)")
            }
        } else {
            print("Bible.json not found")
        }
    }
    
    func loadChapters(for book: Int) {
        let chaptersInBook = verses.filter { $0.book == book }.map { $0.chapter }
        self.chapters = Array(Set(chaptersInBook)).sorted()
    }
    
    func loadVerses(for book: Int, chapter: Int) {
        self.versesInChapter = verses.filter { $0.book == book && $0.chapter == chapter }
    }
}
struct Versees: Codable, Identifiable {
    let id = UUID()
    let text: String
    let book: Int
    let verse: Int
    let chapter: Int
    let topic: String?
    let reference: String
    let strongsNumbers: [String]
    
    enum CodingKeys: String, CodingKey {
        case text
        case book
        case verse
        case chapter
        case topic
        case reference
        case strongsNumbers = "strongs_numbers"
    }
}
struct ManualChooser: View {
    @State private var isShowingBooks = true
    @State private var isShowingChapter = false
    @State private var isShowingVerse = false

    @StateObject private var viewModel = VerseViewModel()
    @Binding var selectedVerseref: String
      var body: some View {
          ScrollView {
              VStack {
                  DisclosureGroup("Books", isExpanded: $isShowingBooks) {
                      LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())] ) {
                          ForEach(viewModel.books, id: \.self) { book in
                              
                              
                              Button(action: {viewModel.selectedBook = book}) {
                                  
                                  
                                  Text(books[book - 1]).tag(book as Int?).frame(width: 120, height: 40)
                              }.buttonBorderShape(.roundedRectangle(radius: 10)).buttonStyle(.bordered).padding()
                          }
                      }.padding()
                  }.disclosureGroupStyle(dgStyle()).padding(.horizontal)
                  .onChange(of: viewModel.selectedBook) {
                      if let book = viewModel.selectedBook {
                          viewModel.loadChapters(for: book)
                          viewModel.selectedChapter = nil
                          withAnimation {
                              isShowingBooks = false
                              isShowingChapter = true
                          }
                      }
                  }
                  
                  if let selectedBook = viewModel.selectedBook {
                      DisclosureGroup("Chapter", isExpanded: $isShowingChapter) {
                          LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible())] ) {
                              ForEach(viewModel.chapters, id: \.self) { chapter in
                                  
                                  Button(action: {viewModel.selectedChapter = chapter}) {
                                      
                                      
                                      Text(String(chapter)).font(.title3).frame(width: 30, height: 25)
                                  }.buttonBorderShape(.roundedRectangle(radius: 5)).buttonStyle(.bordered)
                              }
                          }
                      }.disclosureGroupStyle(dgStyle()).padding(.horizontal)
                      .onChange(of: viewModel.selectedChapter) {
                          debugPrint(viewModel.chapters)
                          if let chapter = viewModel.selectedChapter {
                              
                              viewModel.loadVerses(for: selectedBook, chapter: chapter)
                              withAnimation {
                                  isShowingChapter = false
                                  isShowingVerse = true
                              }
                          }
                      }
                  }
                  
                  if let selectedChapter = viewModel.selectedChapter {
                      DisclosureGroup("Verse", isExpanded: $isShowingVerse) {
                          LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()),GridItem(.flexible()),GridItem(.flexible())] ) {
                              ForEach(viewModel.chapters, id: \.self) { verse in
                                  
                                  Button(action: {viewModel.verse = verse - 1}) {
                                      
                                      
                                      Text(String(verse)).font(.title3).frame(width: 30, height: 25)
                                  }.buttonBorderShape(.roundedRectangle(radius: 5)).buttonStyle(.bordered)
                              }
                          }
                      }.disclosureGroupStyle(dgStyle()).padding(.horizontal)   .onChange(of: viewModel.verse) {
                          selectedVerseref = "\(books[(viewModel.selectedBook  ?? 1 ) - 1]) \(selectedChapter):\(viewModel.verse + 1)"
                          
                      }
                  }
              }.onChange(of: selectedVerseref) {
                  print(selectedVerseref)
              }
          }.presentationSizing(.form.sticky())
          }
      
  }

