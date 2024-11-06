//
//  ContentView.swift
//  Scrible
//
//  Created by Jadon Gearhart on 11/6/24.
//

import SwiftUI
import PencilKit
import UniformTypeIdentifiers
import SwiftData
import SwipeActions
import AlertKit
import Combine
import UIKit
import AppIntents
func getFontDesign(from string: String) -> Font.Design {
        switch string {
        case "default":
            return .default
        case "monospaced":
            return .monospaced
        case "rounded":
            return .rounded
        case "serif":
            return .serif
        default:
            return .default
        }
    }
struct placeholder: View {
    var placeHolder: Bool
    var body: some View {
        if placeHolder {
            Text("")

        }
    }
}
class VersereturnViewModel: ObservableObject {
    @Published var model: VersereturnModel

    init(model: VersereturnModel) {
        self.model = model
    }
}



struct DrawingView: View {

    @Binding var navPath: NavigationPath
    @State private var canvasView = PKCanvasView()
    @State private var showSheet = false
    @State private var showPopover = false
    @State private var notes: [String] = []
    @State private var tool: PKTool = PKInkingTool(.pen)
    @State private var canvasDelegate = CanvasViewDelegate()
    @StateObject private var popoverState = PopoverState()
    @State var open = PassthroughSubject<Void, Never>()
    @Query var highlights: [ScribleHighlights]
    @AppStorage("highlightColor") private var highlightColor: HighlightColor = .yellow
    @Query var destinations: [ScribleSaves]
    @StateObject private var verseText = VersereturnViewModel(model: VersereturnModel(verses: [], reference: "", notes: [], indicesWithNotes: []))
    @AppStorage("appicon") private var appicon = "default"
        @AppStorage("margin") private var margin = 0.0
        @AppStorage("font") private var font = "regular"
    @Binding var reference: String
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
    @State private var currentDrawing: PKDrawing? = nil
    @State private var currentRef: BibleReference = BibleReference(id: UUID(), book: "", chapter: 1, verse: 1)
    @Environment(\.modelContext) var modelContext
    @State private var showStrongs = false
    //@State private var strongsData:WordByWordData = WordByWordData(reference: "", book: "", chapter: 0, verse: 0)
    @State private var strongsData:WordByWordData?

    var body: some View {
         
            ScrollViewReader { value in
                
                ScrollView {
                    ZStack {
                        VStack {
                            Group {
                         
                                SwipeViewGroup {
                                    ForEach(verseText.model.verses.indices, id: \.self) { index in
                                        let referencee = parseBibleReference("\(reference)")
                                        if let referencee = referencee {
                                            let currentReference = "\(referencee.book) \(referencee.chapter):\(referencee.verse)"
                                            let verseReference = "\(referencee.book) \(referencee.chapter):\(getIndex(index))"
                                            SwipeView {
                                                
                                                HStack(alignment: .top) {
                                                    Text("\(getIndex(index)) ")
                                                        .font(.callout)
                                                        .fontWeight(.medium)
                                                        .alignmentGuide(.leading) { _ in 0 }
                                                    if let isHighlight = highlights.first(where: {$0.reference == "\(verseReference)" } ) {
                                                        Text(verseText.model.verses[index])
                                                            .font(.title2)
                                                            .fontWeight(.medium)
                                                            .background {
                                                                
                                                              
                                                                            isHighlight.color.color.opacity(0.5)
                                                                
                                                            }
                                                              
                                                            
                                                            .alignmentGuide(.leading) { _ in 0 }
                                                            .fontDesign(getFontDesign(from: font))
                                                    } else {
                                                        
                                                        Text(verseText.model.verses[index])
                                                            .font(.title2)
                                                            .fontWeight(.medium)
                                                            .foregroundStyle(verseReference == currentReference ? Color.blue : Color.primary)
                                                            .alignmentGuide(.leading) { _ in 0 }
                                                            .fontDesign(getFontDesign(from: font))
                                                    }
                                                    
                                              
                                                    
                                                    
                                                }.onTapGesture(count: 2) {
                                                    if let isHighlight = highlights.first(where: {$0.reference == "\(verseReference)" } ) {
                                                        DispatchQueue.global(qos: .userInitiated).async {
                                                            modelContext.delete(isHighlight)
                                                        }
                                                    }
                                                    else {
                                                        print(verseReference)
                                                        print("Highlighting!")
                                                        let newHighlight = ScribleHighlights(date: .now, reference: "\(verseReference)", id: UUID(), verseText: verseText.model.verses[index], color: highlightColor)
                                                        DispatchQueue.global(qos: .userInitiated).async {

                                                            modelContext.insert(newHighlight)
                                                        }
                                                    }
                                                }.id(getIndex(index))
                                            }
                                            
                                            
                                        leadingActions: { context in
                                            SwipeAction("Share", systemImage: "square.and.arrow.up", backgroundColor: .purple) {
                                                showMoreInfoSheet = true
                                                print("p")
                                                context.state.wrappedValue = .closed
                                            }.allowSwipeToTrigger().foregroundStyle(.white)
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                            
                                        }
                                        trailingActions: { context in
                                            SwipeAction("Copy",   systemImage: "doc.on.doc.fill", backgroundColor: .orange) {
                                                let clipboard = UIPasteboard.general
                                                clipboard.setValue("\(verseText.model.verses[index]) \n \(reference)", forPasteboardType: UTType.plainText.identifier)
                                                context.state.wrappedValue = .closed
                                            }.foregroundStyle(.white)
                                            
                                            
                                            SwipeAction("More Info", systemImage: "table", backgroundColor: .blue) {
                                                print(strongsData)

                                                    strongsData = WordByWordData(reference: reference, book: referencee.book, chapter: referencee.chapter, verse: getIndex(index))

                                                showStrongs.toggle()
                                                    print("Appended to navPath: \(navPath)")
                                                    context.state.wrappedValue = .closed
                                                    
                                                
                                            }    .allowSwipeToTrigger().foregroundStyle(.white)
                                            
                                            
                                            
                                        } .swipeActionsStyle(.mask)
                                                .swipeActionCornerRadius(0)
                                                .swipeSpacing(0)
                                                .swipeMinimumDistance(50)
                                                .swipeActionsMaskCornerRadius(0)
                                                .swipeMinimumPointToTrigger(400) .sheet(isPresented: $showMoreInfoSheet) {
                                                    ShareSheet(items: ["\(verseText.model.verses[index]) \n \(reference):\(getIndex(index))"])
                                                    // Extract parts from the reference string
                                                }
                                            
                                            
                                            
                                        }
                                        }.frame(maxWidth: CGFloat(margin), alignment: .leading)
                                            .multilineTextAlignment(.leading)
                                    
                                }
                                
                            }
                            
                            
                            Text("\n\n\n\n\n\n")
                        }.frame(maxWidth: .infinity, maxHeight: .infinity)
                        if boop {
                            GeometryReader { geometry in
                                CanvasRepresentation(canvasView: $canvasView, tool: $tool)
                                    
                                
                            }
                        }
                    }
                    
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onChange(of: reference) {
                        updateCanvasViewForReference()
                        if let ref = parseBibleReference(reference) {
                            withAnimation {
                                value.scrollTo(ref.verse - 1, anchor: .center)
                            }
                        }
                }

            }
            .toolbar {
                ToolbarItem {
                    Button(action: { withAnimation {boop.toggle()} }) {
                        Image(systemName: boop ? "pencil.slash" : "pencil")
                            .contentTransition(.symbolEffect(.replace))
                    }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    ToolChanger(tool: $tool)
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
                  
                }
            }.onAppear {
                var r = parseBibleReference("")
                if reference == "John 3:16" && lastVerse.isEmpty {
                     r = parseBibleReference("John 3:16")
                    
                    
            }
                else if reference == "John 3:16" {
                     r = parseBibleReference(lastVerse)
                    reference = lastVerse
  

                }
                else {
                     r = parseBibleReference(reference)
                }
                
                    
                
                
                    
                
            
                
                if let ref = r {
                    
                    //let r = BibleReference(book: "John", chapter: 3, verse: 16)
                    getChapter(chapter: ref.chapter, book: ref.book) { completion in
                        DispatchQueue.main.async {
                            verseText.model = completion
                        }
                            
                            //modelContext.insert(setLastVerse)
                            updateCanvasViewForReference()
                        
                        
                        
                        }
                    }
                for i in destinations {
                    print("ASHHHHHHH")
                    print(i.chapter)
                }
            }  .inspector(item: $strongsData) { d in
                            WordByWordView(reference: d.reference, chapter: d.chapter, verse: d.verse, book: d.book)
                        
                    
                    .navigationTitle("Strongs Concordance")
                    .toolbar {
                        Button(action: { strongsData = nil }) {
                            Image(systemName:"sidebar.squares.trailing")
                        }
                    }
                .inspectorColumnWidth(450)
            }
       
        
    }

    private func updateCanvasViewForReference() {
        print("Attempting to update canvas for \(reference)")

        guard let ref = parseBibleReference(reference) else {
            print("Invalid reference: \(reference)")
            return
        }
        currentRef = ref
        let currentReference = "\(currentRef.book) \(currentRef.chapter)"
        print("Parsed current reference: \(currentReference)")

        // Attempt to load the drawing for the current reference
        if let drawingData = destinations.first(where: { $0.chapter == currentReference })?.drawing {
            do {
                canvasView.drawing = try PKDrawing(data: drawingData)
                print("Loaded drawing for \(currentReference)")
            } catch {
                print("Failed to load drawing data for \(currentReference): \(error)")
                canvasView.drawing = PKDrawing()
            }
        } else {
            print("No drawing found for \(currentReference), starting with a blank canvas.")
            canvasView.drawing = PKDrawing()
        }

        // Set the delegate after the drawing is loaded
        canvasView.delegate = canvasDelegate

        canvasDelegate.onDrawingChange = {
            saveDrawing()
          /*  if "\(ref.book) \(ref.chapter):\(ref.verse)" != reference {
                print("STAT%E PRIVCNME")
                
            }
            else {
                print("not first")
                // Ensure the correct reference is used
                let saveReference = currentReference
                print(saveReference)
                print("Attempting to save drawing for \(saveReference)")
                if let chapt = destinations.first(where: {$0.chapter == saveReference}) {
                    chapt.drawing = canvasView.drawing.dataRepresentation()
                }
                else {
                    print("first save")
                    let save = ScribleSaves(date: .now, chapter: saveReference, id: UUID(), drawing: canvasView.drawing.dataRepresentation())
                    DispatchQueue.global(qos: .userInitiated).async {
                        
                        modelContext.insert(save)
                    }
                    print("Saved drawing for chapter: \(saveReference)")
                }
            }*/
        }
    }
    private func saveDrawing() {
        guard let ref = parseBibleReference(reference) else {
            print("Invalid reference: \(reference)")
            return
        }
        let saveReference = "\(ref.book) \(ref.chapter)"
        let save = ScribleSaves(date: .now, chapter: saveReference, id: UUID(), drawing: canvasView.drawing.dataRepresentation())

        modelContext.insert(save)
        try? modelContext.save()
    }
    private func goToNextVerse() {
          if let referencee = parseBibleReference(reference) {
              let nextVerse = referencee.chapter + 1
              let newReference = "\(referencee.book) \(nextVerse):1"
              reference = newReference
          }
      }

      private func goToPreviousVerse() {
          if let referencee = parseBibleReference(reference) {
              let prevVerse = max(referencee.chapter - 1, 1)
              let newReference = "\(referencee.book) \(prevVerse):1"
              reference = newReference
          }
      }
    private var combinedVariables: String {
        return "\(boop)\(reference)"
    }
    private func scaleAndCenterDrawing(to size: CGSize) {
        let drawingBounds = canvasView.drawing.bounds
        guard drawingBounds.width > 0, drawingBounds.height > 0 else {
            return // Avoid scaling if drawing bounds are invalid
        }

        let scaleX = size.width / drawingBounds.width
        let scaleY = size.height / drawingBounds.height
        let scale = min(scaleX, scaleY)

        // Calculate the scaled size of the drawing
        let scaledDrawingSize = CGSize(width: drawingBounds.width * scale, height: drawingBounds.height * scale)

        // Center the drawing within the canvas view
        let offsetX = (size.width - scaledDrawingSize.width) / 2
        let offsetY = (size.height - scaledDrawingSize.height) / 2

        // Apply scaling and translation to the canvas view
        canvasView.transform = CGAffineTransform(translationX: offsetX, y: offsetY).scaledBy(x: scale, y: scale)

        // Adjust the content size to be the same as the view size to prevent scrolling
        canvasView.contentSize = size
    }
}
func getIndex(_ index: Int) -> Int {
    return index + 1
}
// Define the popover state
class PopoverState: ObservableObject {
    @Published var popoverIndex: Int? = nil

    func togglePopover(index: Int) {
        if popoverIndex == index {
            popoverIndex = nil
        } else {
            popoverIndex = index
        }
    }
}

// Example model for demonstration purposes
let exampleModel = VersereturnModel(
    verses: [],
    reference: "",
    notes: [],
    indicesWithNotes: []
)

// Define the content view with the sidebar
enum Selection: Hashable {
    case bible, saved, settings, notes
}
func getstupidimage(data: Data) -> UIImage {
    var image = UIImage()
    do {
        let pk = try PKDrawing(data: data)
         image = pk.image(from: pk.bounds, scale: UIScreen.main.scale)
        
    } catch {
        print("issue")

        print(error)
    }
    return image
    
}
struct BibleHomeView: View {
    @Environment(\.modelContext) var mod
    @Binding var verseReference: String
    @AppStorage("splitScreen") private var splitScreen = false
    @State private var navPath = NavigationPath()
    var body: some View {
        NavigationStack(path: $navPath) {
            Group {
            
                DrawingView(navPath: $navPath, reference: $verseReference)
                    .modelContext(mod)
            }
            .navigationBarTitle("Bible").navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: WordByWordData.self) { data in
                WordByWordView(reference: data.reference, chapter: data.chapter, verse: data.verse, book: data.book)
            }
        }
    }
}


struct BibleReference: Codable, Identifiable, Equatable {
    let id: UUID
    let book: String
    let chapter: Int
    let verse: Int
    var fullReference: String {
        "\(book) \(chapter):\(verse)"
    }
}

func parseBibleReference(_ reference: String) -> BibleReference? {
    // Regular expression to match the reference pattern
    let pattern = "^(\\d*\\s*\\w+\\s*\\w*)\\s+(\\d+):(\\d+)$"
    let regex = try! NSRegularExpression(pattern: pattern)
    let nsString = reference as NSString
    let results = regex.matches(in: reference, range: NSRange(location: 0, length: nsString.length))

    // Ensure we have a match
    guard let match = results.first else {
        print("Invalid reference format.")
        return nil
    }

    // Extract book, chapter, and verse
    let bookRange = match.range(at: 1)
    let chapterRange = match.range(at: 2)
    let verseRange = match.range(at: 3)
    
    let book = nsString.substring(with: bookRange).trimmingCharacters(in: .whitespaces)
    guard let chapter = Int(nsString.substring(with: chapterRange)),
          let verse = Int(nsString.substring(with: verseRange)) else {
        print("Invalid chapter or verse number.")
        return nil
    }

    return BibleReference(id: UUID(), book: book, chapter: chapter, verse: verse)
}
struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
struct InspectorViewModifierr<Item: Equatable, InspectorView: View>: ViewModifier {
    
    @Binding var item: Item?
    @ViewBuilder var inspectorContent: (Item) -> InspectorView
    
    func body(content: Content) -> some View {
        content
            .inspector(isPresented: _item.map(to: { $0 != nil }, from: { _ in item })) {
                item.map(inspectorContent)
            }
    }
}

extension View {
    func inspector<Item: Equatable, InspectorContent: View>(item: Binding<Item?>, @ViewBuilder content: @escaping (Item) -> InspectorContent) -> some View {
        self.modifier(InspectorViewModifierr(item: item, inspectorContent: content))
    }
}

extension Binding {
    func map<T>(to: @escaping (Value) -> T, from: @escaping (T) -> Value) -> Binding<T> {
        Binding<T>(
            get: { to(self.wrappedValue) },
            set: { (value: T) in self.wrappedValue = from(value) }
        )
    }
}
