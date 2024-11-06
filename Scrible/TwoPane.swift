import SwiftUI
import PencilKit
import UniformTypeIdentifiers
import SwiftData
import SwipeActions
import AlertKit
import Combine
import UIKit

/*struct TwoPaneDrawingView: View {
    @State private var newVerseText: (VersereturnModel, VersereturnModel) = (VersereturnModel(verses: [], reference: "", notes: [], indicesWithNotes: []), VersereturnModel(verses: [], reference: "", notes: [], indicesWithNotes: []))
    @Binding var navPath: NavigationPath
    @State private var canvasView = PKCanvasView()
    @State private var isDrawing = false
    @State private var showSheet = false
    @State private var showPopover = false
    @State private var notes: [String] = []
    @State private var canvasDelegate = CanvasViewDelegate()
    @StateObject private var popoverState = PopoverState()
    @State var open = PassthroughSubject<Void, Never>()
    @Query var highlights: [ScribleHighlights]
    @Environment(\.modelContext) var modelContext
    @Query var destinations: [ScribleSaves]
    @StateObject private var verseText = VersereturnViewModel(model: VersereturnModel(verses: [], reference: "", notes: [], indicesWithNotes: []))
    @AppStorage("appicon") private var appicon = "default"
    @AppStorage("margin") private var margin = 0.0
    @AppStorage("font") private var font = "regular"
    @State private var reference = "Verse"
    @State private var showSettings = false
    @AppStorage("boop") private var boop = true
    @State private var lastCanvasHeight = 0.0
    @State private var showMoreInfoSheet = false
    @State private var offset = CGSize.zero
    @AppStorage("lastVerse") var lastVerse = ""
    @State private var selectedVerseNum = 1
    @State private var showWordByWord = false
    @State private var showMenu = false
    @State private var menuPosition: CGFloat = 0.0
    @State private var indexOffset = 0

    var body: some View {
        ScrollViewReader { value in
            ScrollView {
                ZStack {
                    HStack {
                        VStack {
                            Group {
                                SwipeViewGroup {
                                    ForEach(newVerseText.0.verses.indices, id: \.self) { index in
                                        let referencee = parseBibleReference("\(reference)")
                                        if let referencee = referencee {
                                            let currentReference = "\(referencee.book) \(referencee.chapter):\(referencee.verse)"
                                            let verseReference = "\(referencee.book) \(referencee.chapter):\(index + 1)"
                                            if let realReference = parseBibleReference(verseReference) {
                                                SwipeView {
                                                    HStack(alignment: .top) {
                                                        Text("\(index + 1) ")
                                                            .font(.callout)
                                                            .fontWeight(.medium)
                                                            .alignmentGuide(.leading) { _ in 0 }
                                                        if let isHighlight = highlights.first(where: { $0.reference == "\(verseReference)" } ) {
                                                            Text(newVerseText.0.verses[index])
                                                                .font(.title2)
                                                                .fontWeight(.medium)
                                                                .background {
                                                                    isHighlight.color.color.opacity(0.5)
                                                                }
                                                                .alignmentGuide(.leading) { _ in 0 }
                                                                .fontDesign(getFontDesign(from: font))
                                                        } else {
                                                            Text(newVerseText.0.verses[index])
                                                                .font(.title2)
                                                                .fontWeight(.medium)
                                                                .foregroundStyle(verseReference == currentReference ? Color.blue : Color.primary)
                                                                .alignmentGuide(.leading) { _ in 0 }
                                                                .fontDesign(getFontDesign(from: font))
                                                        }
                                                    }
                                                    .onTapGesture(count: 2) {
                                                        
                                                        if let isHighlight = highlights.first(where: { $0.reference == "\(verseReference)" } ) {
                                                            modelContext.delete(isHighlight)
                                                        } else {
                                                            print(verseReference)
                                                            print("Highlighting!")
                                                            let newHighlight = ScribleHighlights(date: .now, reference: "\(verseReference)", id: UUID(),verseText: verseText.model.verses[index], color: .yellow)
                                                            modelContext.insert(newHighlight)
                                                        }
                                                    }
                                                    .id(index + 1)
                                                }
                                                leadingActions: { context in
                                                    SwipeAction("Share", systemImage: "square.and.arrow.up", backgroundColor: .purple) {
                                                        showMoreInfoSheet = true
                                                        print("p")
                                                        context.state.wrappedValue = .closed
                                                    }.allowSwipeToTrigger().foregroundStyle(.white)
                                                }
                                                trailingActions: { context in
                                                    SwipeAction("Copy", systemImage: "doc.on.doc.fill", backgroundColor: .orange) {
                                                        let clipboard = UIPasteboard.general
                                                        clipboard.setValue("\(verseText.model.verses[index]) \n \(reference)", forPasteboardType: UTType.plainText.identifier)
                                                        context.state.wrappedValue = .closed
                                                    }.foregroundStyle(.white)
                                                    SwipeAction("More Info", systemImage: "table", backgroundColor: .blue) {
                                                        navPath.append(WordByWordData(reference: verseReference, book: realReference.book, chapter: realReference.chapter, verse: realReference.verse))
                                                        print("Appended to navPath: \(navPath)")
                                                        context.state.wrappedValue = .closed
                                                    }.allowSwipeToTrigger().foregroundStyle(.white)
                                                }
                                                .swipeActionsStyle(.mask)
                                                .swipeActionCornerRadius(0)
                                                .swipeSpacing(0)
                                                .swipeActionsMaskCornerRadius(0)
                                                .swipeMinimumPointToTrigger(400)
                                                .sheet(isPresented: $showMoreInfoSheet) {
                                                    ShareSheet(items: ["\(verseText.model.verses[index]) \n \(reference):\(index + 1)"])
                                                }
                                            }
                                        }
                                    }
                                    .frame(maxWidth: CGFloat(margin), alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                }
                            }
                            Spacer()
                        }
                        VStack {
                            Group {
                                SwipeViewGroup {
                                    ForEach(newVerseText.1.verses.indices, id: \.self) { inde in
                                        let index = inde + newVerseText.0.verses.count
                                        let referencee = parseBibleReference("\(reference)")
                                        if let referencee = referencee {
                                            let currentReference = "\(referencee.book) \(referencee.chapter):\(referencee.verse)"
                                            let verseReference = "\(referencee.book) \(referencee.chapter):\(index + 1)"
                                            if let realReference = parseBibleReference(verseReference) {
                                                SwipeView {
                                                    HStack(alignment: .top) {
                                                        Text("\(index + 1) ")
                                                            .font(.callout)
                                                            .fontWeight(.medium)
                                                            .alignmentGuide(.leading) { _ in 0 }
                                                        if let isHighlight = highlights.first(where: { $0.reference == "\(verseReference)" } ) {
                                                            Text(newVerseText.1.verses[inde])
                                                                .font(.title2)
                                                                .fontWeight(.medium)
                                                                .background {
                                                                    isHighlight.color.color.opacity(0.5)
                                                                }
                                                                .alignmentGuide(.leading) { _ in 0 }
                                                                .fontDesign(getFontDesign(from: font))
                                                        } else {
                                                            Text(newVerseText.1.verses[inde])
                                                                .font(.title2)
                                                                .fontWeight(.medium)
                                                                .foregroundStyle(verseReference == currentReference ? Color.blue : Color.primary)
                                                                .alignmentGuide(.leading) { _ in 0 }
                                                                .fontDesign(getFontDesign(from: font))
                                                        }
                                                    }
                                                    .onTapGesture(count: 2) {
                                                        if let isHighlight = highlights.first(where: { $0.reference == "\(verseReference)" } ) {
                                                            modelContext.delete(isHighlight)
                                                        } else {
                                                            print(verseReference)
                                                            print("Highlighting!")
                                                            let newHighlight = ScribleHighlights(date: .now, reference: "\(verseReference)", id: UUID(),verseText: verseText.model.verses[index], color: .yellow)
                                                            modelContext.insert(newHighlight)
                                                        }
                                                    }
                                                    .id(inde + 1)
                                                }
                                                leadingActions: { context in
                                                    SwipeAction("Share", systemImage: "square.and.arrow.up", backgroundColor: .purple) {
                                                        showMoreInfoSheet = true
                                                        print("p")
                                                        context.state.wrappedValue = .closed
                                                    }.allowSwipeToTrigger().foregroundStyle(.white)
                                                }
                                                trailingActions: { context in
                                                    SwipeAction("Copy", systemImage: "doc.on.doc.fill", backgroundColor: .orange) {
                                                        let clipboard = UIPasteboard.general
                                                        clipboard.setValue("\(newVerseText.1.verses[inde]) \n \(reference)", forPasteboardType: UTType.plainText.identifier)
                                                        context.state.wrappedValue = .closed
                                                    }.foregroundStyle(.white)
                                                    SwipeAction("More Info", systemImage: "table", backgroundColor: .blue) {
                                                        navPath.append(WordByWordData(reference: verseReference, book: realReference.book, chapter: realReference.chapter, verse: realReference.verse))
                                                        print("Appended to navPath: \(navPath)")
                                                        context.state.wrappedValue = .closed
                                                    }.allowSwipeToTrigger().foregroundStyle(.white)
                                                }
                                                .swipeActionsStyle(.mask)
                                                .swipeActionCornerRadius(0)
                                                .swipeSpacing(0)
                                                .swipeActionsMaskCornerRadius(0)
                                                .swipeMinimumPointToTrigger(400)
                                                .sheet(isPresented: $showMoreInfoSheet) {
                                                    ShareSheet(items: ["\(verseText.model.verses[index]) \n \(reference):\(index + 1)"])
                                                }
                                            }
                                        }
                                    }
                                    .frame(maxWidth: CGFloat(margin), alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                }
                            }
                            Spacer()
                        }
                    }
                    if boop {
                        GeometryReader { geometry in
                            CanvasRepresentation(canvasView: $canvasView, isShowingTools: $isDrawing)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .edgesIgnoringSafeArea(.all)
                        }
                    }
                }
                .onChange(of: reference) {
                    if let refee = parseBibleReference(reference) {
                       
                        withAnimation {
                            value.scrollTo(refee.verse - 1, anchor: .center) // Scroll to the correct verse index
                        }
                        print(verseText)
                        if let n = verseText.model.splitAtMidpoint() {
                            newVerseText = n
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .toolbar {
            ToolbarItem {
                Button(action: { withAnimation { boop.toggle() } }) {
                    Image(systemName: boop ? "pencil.slash" : "pencil")
                        .contentTransition(.symbolEffect(.replace))
                }
            }
            ToolbarItemGroup(placement: .bottomBar) {
                Button(action: { isDrawing.toggle() }) {
                    Image(systemName: "pencil")
                }
                .foregroundStyle(Color(UIColor.label))
                .padding()
                Spacer()
                Button(action: { showSheet = true }) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text(reference)
                    }
                }
                .foregroundStyle(Color(UIColor.label))
                .padding()
                .sheet(isPresented: $showSheet) {
                    ChapterChoose(verseText: $verseText.model, canvasView: $canvasView, reference: $reference, notes: $notes)
                }
                Spacer()
                Button(action: { showSettings.toggle() }) {
                    Image(systemName: "gear")
                }
                .foregroundStyle(Color(UIColor.label))
                .padding()
            }
        }
        .onAppear {
            let r = parseBibleReference(lastVerse)
            if let ref = r {
                getChapter(chapter: ref.chapter, book: ref.book) { completion in
                    verseText.model = completion
                    reference = lastVerse
                }
            }
        }
    }

    private var combinedVariables: String {
        return "\(boop)\(reference)"
    }
}*/
