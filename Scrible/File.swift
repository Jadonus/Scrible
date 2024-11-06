//
//  File.swift
//  Scrible
//
//  Created by Jadon Gearhart on 5/17/24.
//
import SwiftUI
import Foundation
import SwiftData
#if(canImport(UIKit))
import PencilKit

class CanvasViewDelegate: NSObject, PKCanvasViewDelegate {
    var onDrawingChange: (() -> Void)?

    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        onDrawingChange?()
    }
}
struct CanvasRepresentation: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var tool: PKTool
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = tool
        canvasView.backgroundColor = .clear
        if let window = UIApplication.shared.windows.first {
            canvasView.becomeFirstResponder()
        }
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        canvasView.tool = tool

           if let window = UIApplication.shared.windows.first {
               uiView.becomeFirstResponder()
           }
       }
   }
#endif
extension String {
    var isInt: Bool {
        return Int(self) != nil
    }
}
struct HighlightedTextView: View {
    let text: String

    var body: some View {
        Text(convertToAttributedString(text))
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func convertToAttributedString(_ htmlText: String) -> AttributedString {
        var attributedString = AttributedString("")

        // Regular expression to match <span class="highlight">...</span>
        let regexPattern = "<span class=\"highlight\">(.*?)</span>"
        guard let regex = try? NSRegularExpression(pattern: regexPattern, options: []) else {
            return AttributedString(htmlText)
        }

        // Find all matches in the text
        let nsString = NSString(string: htmlText)
        let matches = regex.matches(in: htmlText, options: [], range: NSRange(location: 0, length: nsString.length))

        var lastIndex = htmlText.startIndex

        // Apply highlighting to each match
        for match in matches {
            let matchRange = match.range(at: 0)
            let highlightedRange = match.range(at: 1)

            // Non-highlighted text before the current match
            let nonHighlightedTextEndIndex = htmlText.index(htmlText.startIndex, offsetBy: matchRange.location)
            let nonHighlightedText = String(htmlText[lastIndex..<nonHighlightedTextEndIndex])
            attributedString += AttributedString(nonHighlightedText)

            // Highlighted text
            if let range = Range(highlightedRange, in: htmlText) {
                let highlightedText = String(htmlText[range])
                var highlightedString = AttributedString(highlightedText)
                highlightedString.foregroundColor = .yellow
                attributedString += highlightedString
            }

            // Update lastIndex to the end of the current match
            lastIndex = htmlText.index(htmlText.startIndex, offsetBy: matchRange.upperBound)
        }

        // Append any remaining text after the last match
        if lastIndex < htmlText.endIndex {
            let remainingText = String(htmlText[lastIndex...])
            attributedString += AttributedString(remainingText)
        }

        return attributedString
    }
}
struct ChapterChoose: View {
    @Binding var verseText: VersereturnModel
    @Binding  var canvasView: PKCanvasView
    @Query var destinations: [ScribleSaves]
    @State private var canvasDelegate = CanvasViewDelegate()
    @Binding var reference: String
    @Binding var notes: [String]
    @Environment(\.modelContext) var modelContext
    @State private var forEachThing: [BibleSearchApiModel] = []
    @State private var book = ""
    @AppStorage("lastVerse") var lastVerse = ""
    @Environment(\.colorScheme) var colorScheme
    @State private var chapter = ""
    @Environment(\.dismiss) var isPres
    var body: some View {
        NavigationStack {
            VStack {
                
                ManualChooser(selectedVerseref: $reference).frame(maxWidth: .infinity, maxHeight: .infinity)
                
                
            }    .searchable(text: $book, placement: .navigationBarDrawer) {
                ForEach(forEachThing, id: \.self) { recomends in
                    Button(action: {
                        
                        reference = "\(recomends.book.name) \(recomends.chapterId):\(recomends.verseId)"
                        
                        
                        
                    }
                    ) {
                        VStack {
                            Text("\(recomends.book.name) \(recomends.chapterId):\(recomends.verseId)").frame(maxWidth: .infinity, alignment: .leading)
                            HighlightedTextView(text: recomends.verse)
                        }.searchCompletion("\(recomends.book.name) \(recomends.chapterId):\(recomends.verseId)")
                        
                    }
                }.foregroundStyle(.primary)
            }.navigationTitle("Search").onChange(of: reference) {
                print(reference)
                if let newRef = parseBibleReference(reference) {
                    getChapter(chapter: newRef.chapter, book: newRef.book) { completion in
                        DispatchQueue.main.async {
                            verseText = completion
                            lastVerse = reference
                            
                            isPres.callAsFunction()
                        }
                        
                        
                    }
                }
            }
            
            .onAppear() {
                Task {
                     makeRecs(current: book)
                }
                
            }.onChange(of: book) {
                Task {
                     makeRecs(current: book)
                }
            }
        }
    }
    @MainActor
    func makeRecs(current: String) {
        if current.isEmpty {
            forEachThing = [
                BibleSearchApiModel(book: Book(id: 1, name: "John", testament: "new"), chapterId: 3, verseId: 16, verse: "For God so loved the world..."),
                BibleSearchApiModel(book: Book(id: 2, name: "Genesis", testament: "old"), chapterId: 1, verseId: 1, verse: "In the beginning..."),
                BibleSearchApiModel(book: Book(id: 3, name: "Psalms", testament: "old"), chapterId: 23, verseId: 1, verse: "The Lord is my shepherd..."),
                BibleSearchApiModel(book: Book(id: 4, name: "Romans", testament: "new"), chapterId: 8, verseId: 28, verse: "And we know that all things work together..."),
                BibleSearchApiModel(book: Book(id: 5, name: "Matthew", testament: "new"), chapterId: 5, verseId: 9, verse: "Blessed are the peacemakers...")
            ]
        } else {
            getSearchResults(query: current) { comp in
                guard let items = comp?.items else {
                    print("No data found for search")
                    return
                }

                let components = current.split(separator: " ")
                var bookNameInput = ""
                var chapterNumber: Int?
                var verseNumber: Int?

                if let firstComponent = components.first, let secondComponent = components.dropFirst().first {
                    if String(firstComponent).isInt {
                        // Handle cases where the book name has a numeral prefix (like "1 Timothy")
                        bookNameInput = "\(firstComponent) \(secondComponent)"
                        
                        if components.count > 2 {
                            let chapterVerse = components.dropFirst(2).joined(separator: " ")
                            let chapterVerseComponents = chapterVerse.split(separator: ":")
                            if chapterVerseComponents.count > 0 {
                                chapterNumber = Int(chapterVerseComponents[0])
                                if chapterVerseComponents.count > 1 {
                                    verseNumber = Int(chapterVerseComponents[1])
                                }
                            }
                        }
                    } else {
                        // Normal case without numerical prefix
                        bookNameInput = String(firstComponent)
                        if components.count > 1 {
                            let chapterVerse = components.dropFirst().joined(separator: " ")
                            let chapterVerseComponents = chapterVerse.split(separator: ":")
                            if chapterVerseComponents.count > 0 {
                                chapterNumber = Int(chapterVerseComponents[0])
                                if chapterVerseComponents.count > 1 {
                                    verseNumber = Int(chapterVerseComponents[1])
                                }
                            }
                        }
                    }
                }

                var recs = [BibleSearchApiModel]()
                if let bookName = closestMatch(to: bookNameInput, in: books) {
                    if let chapterNumber = chapterNumber {
                        let matchedReference = BibleSearchApiModel(
                            book: Book(id: 1, name: bookName, testament: ""),
                            chapterId: chapterNumber,
                            verseId: verseNumber ?? 1,
                            verse: ""
                        )
                        recs.append(matchedReference)
                    }
                }

                for item in items where !recs.contains(where: {
                    $0.book.name == item.book.name && $0.chapterId == item.chapterId && $0.verseId == item.verseId
                }) {
                    recs.append(item)
                }
                
                forEachThing = recs
            }
        }
    }

}
    extension Array {
    func pick(_ n: Int) -> [Element] {
        guard count >= n else {
            fatalError("The count has to be at least \(n)")
        }
        guard n >= 0 else {
            fatalError("The number of elements to be picked must be positive")
        }

        let shuffledIndices = indices.shuffled().prefix(upTo: n)
        return shuffledIndices.map {self[$0]}
    }
}
func levenshtein(_ a: String, _ b: String) -> Int {
    guard !a.isEmpty && !b.isEmpty else {
        // Return the length of the non-empty string or 0 if both are empty
        return max(a.count, b.count)
    }
    
    let a = Array(a)
    let b = Array(b)
    let (m, n) = (a.count, b.count)
    var dp = [[Int]](repeating: [Int](repeating: 0, count: n + 1), count: m + 1)

    for i in 1...m { dp[i][0] = i }
    for j in 1...n { dp[0][j] = j }

    for i in 1...m {
        for j in 1...n {
            if a[i - 1] == b[j - 1] {
                dp[i][j] = dp[i - 1][j - 1]
            } else {
                dp[i][j] = min(dp[i - 1][j - 1] + 1, min(dp[i - 1][j] + 1, dp[i][j - 1] + 1))
            }
        }
    }

    return dp[m][n]
}

// Function to find the closest match using Levenshtein distance
func closestMatch(to input: String, in options: [String]) -> String? {
    guard !input.isEmpty, !options.isEmpty else { return nil }
    
    // Find the closest match using Levenshtein distance
    return options.min(by: { levenshtein(input, $0) < levenshtein(input, $1) })
}
