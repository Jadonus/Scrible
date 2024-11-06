protocol DrawingChangeDelegate: AnyObject {
    func canvasViewDrawingDidChange()
}
import TipKit
// Notes.swift
import SwiftUI
import PencilKit
import Vision
import SwiftData
func containsBibleReference(_ text: String, books: [String]) -> [String] {
    print(text)
    let booksPattern = books.joined(separator: "|")
    let simplePattern = "(\(booksPattern))\\.?\\s?(\\d{1,3}):\\s?(\\d{1,3}(?:\\s?\\-\\s?\\d{1,3})?)"
    let complexPattern = "(?:(\(booksPattern))\\.?\\s?(\\d{1,3}):\\s?(\\d{1,3}(?:\\s?\\-\\s?\\d{1,3})?)\\,?\\&?\\s?(\\d{1,3}(?:\\,|\\&)\\s?|\\d{1,3}\\s?\\-\\s?\\d{1,3})?)"
    
    let regexPattern = "\(simplePattern)|\(complexPattern)"
    
    do {
        let regex = try NSRegularExpression(pattern: regexPattern, options: [])
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        
        let results = matches.map { match -> String in
            let matchRange = Range(match.range, in: text)!
            return String(text[matchRange])
        }
        
        return results
    } catch {
        print("Failed to create regex: \(error)")
        return []
    }
}

struct IndividualVerse: Identifiable {
    let id = UUID()
    let name: String
}

class NotesViewModel: ObservableObject, DrawingChangeDelegate {
    @Published var canvasView = PKCanvasView()
    @Published var recognizedText: [RecognizedTextWithPosition] = []
    @Published var verse: IndividualVerse?
    @Published var expandedReference: BibleReference?
    @Published var buttons: [NoteRef] = []
    @Published var notePage: Int = 1
    @Published var verseText = ""
    @Published var selectedReference: String = ""
    @Published var showChapterChooser = false
    @Published var currentLocation: CGPoint = .zero
    var modelContext: ModelContext
    var page: Int
    init(modelContext: ModelContext, page: Int) {
     
        self.modelContext = modelContext
        self.page = page
        self.notePage = page
    }
    func canvasViewDrawingDidChange() {
        saveNote()  // Save note when drawing changes
    }
    func toggleExpansion(for reference: BibleReference) {
        if expandedReference == reference {
            expandedReference = nil  // Collapse if already expanded
        } else {
            
            getVerse(reference.fullReference) { v in
                self.verseText = v
            }
            expandedReference = reference  // Expand the selected reference

         
        }
    }

    func recognizeHandwriting() {
        guard let drawingImage = canvasView.drawing.image(from: canvasView.bounds, scale: UIScreen.main.scale).cgImage else {
            print("Failed to convert drawing to CGImage")
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            guard let results = request.results as? [VNRecognizedTextObservation], !results.isEmpty else {
                self.recognizedText = []
                return
            }
            
            self.recognizedText = results.compactMap { observation in
                guard let candidate = observation.topCandidates(1).first else { return nil }
                let text = candidate.string
                let position = self.convertBoundingBoxToPoint(observation.boundingBox)
                return RecognizedTextWithPosition(text: text, position: position)
            }
        }
        
        let handler = VNImageRequestHandler(cgImage: drawingImage)
        try? handler.perform([request])
    }

    func convertBoundingBoxToPoint(_ boundingBox: CGRect) -> CGPoint {
        let width = canvasView.bounds.width
        let height = canvasView.bounds.height
        let x = boundingBox.minX * width
        let y = (1 - boundingBox.maxY) * height
        return CGPoint(x: x, y: y)
    }
    
    func saveNote() {
        // Update modelContext to save the current page's state
        let note = NoteSaves(date: .now, page: notePage, drawing: canvasView.drawing.dataRepresentation(), id: UUID(), buttons: buttons)
        // Insert and save changes
        modelContext.insert(note)
        try? modelContext.save()
        print("Note saved for page \(notePage)")
    }
    
    func loadPage(notes: [NoteSaves]) {
        if let savedNote = notes.first(where: { $0.page == notePage }) {
            buttons = savedNote.buttons
            canvasView.drawing = try! PKDrawing(data: savedNote.drawing)
        } else {
            buttons = []
            canvasView.drawing = PKDrawing()
        }
    }
}

struct NoteRef: Codable {
    var position: CGPoint
    var reference: BibleReference
 // Stroke representing the button's position
}

struct NotebookLines: View {
    let lineColor: Color = Color.gray.opacity(0.3)
    let margin: CGFloat = 20  // Set the margin for the spacing around the lines

    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let spacing: CGFloat = 40  // Line spacing
                var y: CGFloat = margin  // Start drawing the lines with a margin at the top
                
                // Adjust the drawing width to account for the margin
                let adjustedWidth = size.width - 2 * margin
                
                while y < size.height {
                    // Draw a horizontal line at each Y position, adjusted for the margin
                    let line = Path { path in
                        path.move(to: CGPoint(x: margin, y: y))  // Start from the left margin
                        path.addLine(to: CGPoint(x: size.width - margin, y: y))  // End at the right margin
                    }
                    
                    context.stroke(line, with: .color(lineColor), lineWidth: 1)
                    y += spacing
                }
            }
        }
    }
}

struct Notes: View {
    @State private var AddVerseTip = AddVerseInNotes()
    @Namespace private var animation
    @Query var notes: [NoteSaves]
    @StateObject private var viewModel: NotesViewModel
    @AppStorage("page") var page = 1
    @State private var canvasDelegate = CanvasViewDelegate()
    @Binding var verseReference: String
    @Binding var tabSelection: Selection
    init(modelContext: ModelContext, page: Int, verseReference: Binding<String>, tabSelection: Binding<Selection>) {
        let viewModel = NotesViewModel(modelContext: modelContext, page: page)
        _viewModel = StateObject(wrappedValue: viewModel)
        _verseReference = verseReference
        _tabSelection = tabSelection
    }

    var body: some View {
        NavigationStack {
            ZStack {
                NotebookLines()

                // Canvas representation
                CanvasRepresentation(canvasView: $viewModel.canvasView, tool: .constant(PKInkingTool(.pen)))
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture(count: 2) { location in
                        print("Tapped!")
                        viewModel.currentLocation = location
                        viewModel.showChapterChooser.toggle()
                    }
                // Buttons on canvas
                ForEach(viewModel.buttons, id: \.position) { button in
                          Group {
                              Button(action: {
                                  withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.5)) {
                                      viewModel.toggleExpansion(for: button.reference)
                                      print("Toggling", viewModel.expandedReference, button.reference)
                                      print(viewModel.expandedReference == Optional(button.reference) ? "Equal" : "Nope")
                                  }
                              }) {
                                  ZStack {
                                      RoundedRectangle(cornerRadius: 16)
                                          //.fill(viewModel.expandedReference == Optional(button.reference) ? Color.blue : Color.green)
                                          .fill(.thinMaterial)
                                          .frame(
                                              width: viewModel.expandedReference == Optional(button.reference) ? 300 : 100,
                                              height: viewModel.expandedReference == Optional(button.reference) ? 100 : 50
                                          )
                                          .shadow(radius: 10)

                                      VStack {
                                          if viewModel.expandedReference == Optional(button.reference) {
                                              // Wrapping the verse text inside the button
                                              Text(viewModel.verseText)
                                                  .font(.caption)
                                                  .foregroundColor(.white)
                                                  .multilineTextAlignment(.center)
                                                  .lineLimit(nil) // Allow unlimited lines
                                                  .padding()
                                                  .frame(width: 280, height: 95) // Fit text inside the expanded button
                                                  .transition(.opacity.combined(with: .scale))
                                          } else {
                                              Text("\(button.reference.book) \(button.reference.chapter):\(button.reference.verse)")
                                                  .font(.headline)
                                                  .foregroundColor(.white)
                                                  .transition(.opacity)
                                          }
                                      }
                                  }
                              }
                              .contextMenu {
                                  Button(action: {
                                      print("Switching to \(button.reference.fullReference)")
                                      verseReference = button.reference.fullReference
                                      tabSelection = .bible
                                      
                                      
                                      
                                  }) {
                                      Label("View full chapter", systemImage: "arrowshape.turn.up.right.fill")
                                  }
                              }
                              .position(button.position)
                          }
                          

                }
                


                               // Page navigation
                               VStack {
                                   TipView(AddVerseTip, arrowEdge: .none).padding()

                    Spacer()
                    HStack {
                        Button(action: { viewModel.notePage -= 1 }) {
                            Image(systemName: "chevron.left")
                                .font(.largeTitle)
                                .padding()
                                .background(.thinMaterial)
                                .clipShape(.circle)
                        }
                        .foregroundStyle(.secondary)
                        .padding()
                        .disabled(viewModel.notePage < 2)

                        Spacer()

                        Button(action: { viewModel.notePage += 1 }) {
                            Image(systemName: "chevron.right")
                                .font(.largeTitle)
                                .padding()
                                .background(.thinMaterial)
                                .clipShape(.circle)
                        }
                        .foregroundStyle(.secondary)
                        .padding()
                    }
                }
            }
            .onChange(of: viewModel.selectedReference) {
                if let r = parseBibleReference(viewModel.selectedReference) {
                    viewModel.showChapterChooser.toggle()
                    let button = NoteRef(position: viewModel.currentLocation, reference: r)
                    
                    withAnimation {
                        viewModel.buttons.append(button)
                    }
                    viewModel.saveNote()
                }
            }
            .sheet(isPresented: $viewModel.showChapterChooser) {
                ManualChooser(selectedVerseref: $viewModel.selectedReference)
            }
            
            .onChange(of: viewModel.notePage) {
                withAnimation {
                    viewModel.loadPage(notes: notes)
                }
            }
            .onDisappear {
                page = viewModel.notePage
            }
            .onAppear {
                viewModel.page = page
                viewModel.loadPage(notes: notes)
                viewModel.canvasView.delegate = canvasDelegate
                canvasDelegate.onDrawingChange = { viewModel.saveNote() }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    PageTurner(page: $viewModel.notePage)
                }
            }
        }
    }

    // Function to adjust the position to prevent the text from being cut off
    func adjustedPosition(for position: CGPoint, in size: CGSize) -> CGPoint {
        let textWidth: CGFloat = 200  // Estimate or dynamically calculate the text width
        let textHeight: CGFloat = 100  // Estimate or dynamically calculate the text height

        var adjustedX = position.x
        var adjustedY = position.y

        // Adjust X-axis position if the text is going out of bounds
        if position.x + textWidth / 2 > size.width {
            adjustedX = size.width - textWidth / 2
        } else if position.x - textWidth / 2 < 0 {
            adjustedX = textWidth / 2
        }

        // Adjust Y-axis position if the text is going out of bounds
        if position.y + textHeight / 2 > size.height {
            adjustedY = size.height - textHeight / 2
        } else if position.y - textHeight / 2 < 0 {
            adjustedY = textHeight / 2
        }

        return CGPoint(x: adjustedX, y: adjustedY)
    }
}
struct RecognizedTextWithPosition: Identifiable {
    let id = UUID()
    let text: String
    let position: CGPoint
}

struct PKCanvasViewWrapper: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    weak var delegate: DrawingChangeDelegate?

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.delegate = context.coordinator
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.drawing = canvasView.drawing
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(delegate: delegate)
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        weak var delegate: DrawingChangeDelegate?

        init(delegate: DrawingChangeDelegate?) {
            self.delegate = delegate
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            delegate?.canvasViewDrawingDidChange()
        }
    }
}



