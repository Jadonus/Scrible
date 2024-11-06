import SwiftUI
import UIKit
import Foundation
import AVFoundation
import AlertKit

@available(iOS 15, *)
struct TestHTMLText: View {
    var html: String
    
    var body: some View {
        Text(html.strippingHTML())
            .font(.title)
            .foregroundColor(.white)
    }
}

extension String {
    func strippingHTML() -> String {
        // Remove HTML tags using regular expression
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}
struct WordByWordData: Hashable {
    var reference,book: String
    var chapter, verse: Int
    
}
struct WordByWordView: View {
    var reference: String
    var chapter: Int
    var verse: Int
    var book: String
    @AppStorage("strongsLink") var strongsLink = "copy"
    @State private var versetext: BibleModel = BibleModel(reference: "", text: "", strongs_numbers: [], chapter: 0, verse: 0, book: 0, topic: "")
    @State private var GreekParse = AncientLanguageDefinitionParseUtil()
    @State private var isExpanded: Bool = false
    @State private var DictData: [StrongsDefReturnModel]?
    @State private var VerseData: HebrewGreekApi = HebrewGreekApi(verse: "", text: "")
    @State private var loading = true
    @State private var showPop = false
    @State private var wordd = ""
    @State private var Speaker: AVSpeechSynthesizer?
    let columns = [
        GridItem(.flexible(minimum: 80)),
        GridItem(.flexible(minimum: 80))
    ]
    
    var body: some View {
        
        ScrollView {
            if loading {
                ProgressView()
                    .onAppear {
                        Task {
                            print("LOADING")
                            versetext = await fetchVerse(chapter: chapter, verse: verse, book: book)
                            Speaker = AVSpeechSynthesizer()
                            loading = false
                        }
                   }
                
            }
            else {
                ForEach(0..<max(versetext.strongs_numbers.count, versetext.text.split(separator: " ").count), id: \.self) { index in
                    let strongsNumber = index < versetext.strongs_numbers.count ? versetext.strongs_numbers[index] : ""
                    let word = index < versetext.text.split(separator: " ").count ? String(versetext.text.split(separator: " ")[index]) : ""
                    HStack {
                        VStack {
                            Text(word)
                                .font(.title2)
                                .fontWeight(.medium)
                                .padding(.horizontal)
                                .frame(maxWidth: 200) // Set the maximum width
                            
                        }
                        Divider()
                        if books.firstIndex(of: book) ?? 0 <= 38 {
                            let g = GreekParse.hebrewString(strongsNumber)
                            
                            VStack(alignment: .leading) {
                                Text(g.word ?? "WORD")
                                    .font(.title2)
                                    .fontWeight(.medium)
                                    .padding(.horizontal)
                                    .onAppear {
                                        print("HEBREW", strongsNumber)
                                    }
                                
                                if let definition = g.definition {
                                    if strongsLink == "copy" {
                                        Button("Strongs \(strongsNumber)") {
                                            UIPasteboard.general.string = "Strongs " + strongsNumber
                                            AlertKitAPI.present(
                                                title: "Copied to Clipboard",
                                                icon: .custom(UIImage(systemName: "doc.on.clipboard.fill")!),
                                                style: .iOS17AppleMusic,
                                                haptic: .success
                                            )
                                        }
                                        .foregroundStyle(.primary)
                                        .padding(.horizontal)
                                    }
                                    else {
                                        Link("Strongs \(strongsNumber)", destination: URL(string: "https://google.com/search?q=Strongs\(strongsNumber)")!)

                                    }
                                    TagView(tags: g.alternateDef?.components(separatedBy: ",") ?? [], isExpanded: $isExpanded)
                                    
                                    Button(action: {
                                        withAnimation {
                                            isExpanded.toggle()
                                        }
                                    }) {
                                        Label(isExpanded ? "LESS" : "MORE", systemImage: "ellipsis")
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal)
                                    
                                    Text(definition)
                                        .padding(.horizontal)
                                }
                                
                                if let pronunciation = g.pronounciation {
                                    Group {
                                        Button(pronunciation) {
                                            do {
                                                try AVAudioSession.sharedInstance().setCategory(.playback)
                                            } catch {
                                                print("Failed to set audio session category: \(error.localizedDescription)")
                                            }
                                            let utterance = AVSpeechUtterance(string: g.word!)
                                            utterance.voice = AVSpeechSynthesisVoice(language: "he")
                                            Speaker!.speak(utterance)
                                        }.bold()
                                    }.padding(.horizontal)
                                }
                            }                            .frame(maxWidth: 800) // Set the maximum width
                            
                        } else {
                            let g = GreekParse.greekString(strongsNumber)
                            
                            VStack(alignment: .leading) {
                                Text(g.word ?? "")
                                    .font(.title2)
                                    .fontWeight(.medium)
                                    .padding(.horizontal)
                                    .onAppear {
                                        print("GREEK", strongsNumber)
                                    }
                                
                                if let definition = g.definition {
                                    Button("Strongs \(strongsNumber)") {
                                        UIPasteboard.general.string = "Strongs " + strongsNumber
                                        AlertKitAPI.present(
                                            title: "Copied to Clipboard",
                                            icon: .custom(UIImage(systemName: "doc.on.clipboard.fill")!),
                                            style: .iOS17AppleMusic,
                                            haptic: .success
                                        )
                                    }
                                    .foregroundStyle(.primary)
                                    .padding(.horizontal)
                                    
                                    TagView(tags: g.alternateDef?.components(separatedBy: ",") ?? [], isExpanded: $isExpanded)
                                    
                                    Button(action: {
                                        withAnimation {
                                            isExpanded.toggle()
                                        }
                                    }) {
                                        Label(isExpanded ? "LESS" : "MORE", systemImage: "ellipsis")
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal)
                                    
                                    Text(definition)
                                        .padding(.horizontal)
                                }
                                
                                if let pronunciation = g.pronounciation {
                                    Group {
                                        Button(pronunciation) {
                                            do {
                                                try AVAudioSession.sharedInstance().setCategory(.playback)
                                            } catch {
                                                print("Failed to set audio session category: \(error.localizedDescription)")
                                            }
                                            
                                            let utterance = AVSpeechUtterance(string: g.pronounciation!)
                                            utterance.voice = AVSpeechSynthesisVoice(language: "en")
                                            Speaker!.speak(utterance)
                                        }.bold()
                                    }.padding(.horizontal)
                                }
                            }                                                   .frame(maxWidth: 800) // Set the maximum width
                            
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    Divider()
                }
              
            }
        }
    }
}



  
struct TagView: View {
    let tags: [String]
    @Binding var isExpanded: Bool

    let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(isExpanded ? tags : Array(tags.prefix(4)), id: \.self) { tag in
                Text(tag)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 1)
                    )
            }
        }
        .padding()
    }
}


extension String {
    func styledTextFromHTML() -> String {
        var text = self
        
        // Replace <em> tags with SwiftUI italic style
        text = text.replacingOccurrences(of: "<em>", with: "")
        text = text.replacingOccurrences(of: "</em>", with: "")
        text = text.replacingOccurrences(of: "em>", with: "")
        
        return String(text)
    }
}
