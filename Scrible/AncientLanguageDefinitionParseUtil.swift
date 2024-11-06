//
//  AncientLanguageDefinitionParseUtil.swift
//  Scrible
//
//  Created by Jadon Gearhart on 6/18/24.
//

import Foundation
import SwiftUI
struct VerseResponse: Decodable {
    let book: String
    let chapter: String
    let verses: String
    let text: String
    let version: String
}

struct Bible: Decodable {
    var books: [String: Bookk]
    
    enum CodingKeys: String, CodingKey {
        case books = ""
    }
}

struct Bookk: Codable {
    var chapters: [String: Chapter]
    
    enum CodingKeys: String, CodingKey {
        case chapters = "Chapter"
    }
}
struct BibleModel: Codable {
    var reference, text: String
    var strongs_numbers: [String]
    var chapter, verse, book: Int
    var topic: String?
    
    
}
struct Chapter: Codable {
    var verses: [String: Verse]
    
    enum CodingKeys: String, CodingKey {
        case verses = "Verse"
    }
}

struct Verse: Codable {
    var text: String
    
    enum CodingKeys: String, CodingKey {
        case text = "en"
    }
}

func parseBible(jsonData: Data) -> Bible? {
    let decoder = JSONDecoder()
    do {
        let bible = try decoder.decode(Bible.self, from: jsonData)
        return bible
    } catch {
        print("Error decoding JSON: \(error)")
        return nil
    }
}

func fetchVerse(chapter: Int, verse: Int, book: String) async -> BibleModel {
    if let url = Bundle.main.url(forResource: "Bible", withExtension: "json") {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let bibleData = try decoder.decode([BibleModel].self, from: data)
            if var foundBibleModel = bibleData.first(where: { $0.chapter == chapter &&
                                                              $0.verse == verse &&
                $0.book - 1 == books.firstIndex(of: book) }) {
                // 'foundBibleModel' now contains the first matching BibleModel object
                // Check word count against strongs_numbers count
                let wordCount = foundBibleModel.text.split(separator: " ").count
                            let strongsCount = foundBibleModel.strongs_numbers.count
                            
                            if wordCount != strongsCount {
                                let difference = abs(wordCount - strongsCount)
                                if wordCount < strongsCount {
                                    // Prepend empty spaces to text
                                    let spacesToAdd = Array(repeating: "N/A", count: difference).joined(separator: " ")
                                    foundBibleModel.text = spacesToAdd +  " " + foundBibleModel.text
                                }
                            }
                            
                           
                           
                           // Print and return the found BibleModel
                           print("Found:", foundBibleModel)
                           return foundBibleModel
            } else {
                print("No matching BibleModel found")
            }
            
            
        } catch {
            print("Error reading or decoding JSON file: \(error)")
        }
    }
    return BibleModel(reference: "", text: "", strongs_numbers: [], chapter: 0, verse: 0, book: 0, topic: "")
}
struct GreekStrongsModel: Decodable {
    let strongs: String?
    let greek: [GreekElement]?
    let pronunciation: Pronunciation?
    let strongs_def: String?
    let kjv_def: String?
    let see: [See]?
    let _strongs: String?
    let __text: String?
    
    enum CodingKeys: String, CodingKey {
        case strongs, greek, pronunciation
        case strongs_def = "strongs_def"
        case kjv_def = "kjv_def"
        case see = "see"
        case _strongs = "_strongs"
        case __text = "__text"
    }
    
    // Custom decoding to handle greek element as both array and single object
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        strongs = try? container.decode(String.self, forKey: .strongs)
        pronunciation = try? container.decode(Pronunciation.self, forKey: .pronunciation)
        strongs_def = try? container.decode(String.self, forKey: .strongs_def)
        kjv_def = try? container.decode(String.self, forKey: .kjv_def)
        _strongs = try? container.decode(String.self, forKey: ._strongs)
        __text = try? container.decode(String.self, forKey: .__text)
        
        // Decode greek element
        if let singleGreekElement = try? container.decode(GreekElement.self, forKey: .greek) {
            greek = [singleGreekElement]
        } else {
            greek = try? container.decode([GreekElement].self, forKey: .greek)
        }
        
        if let singleSeeElement = try? container.decode(See.self, forKey: .see) {
            see = [singleSeeElement]
        } else {
            see = try? container.decode([See].self, forKey: .see)
        }
    }
}

// MARK: - GreekElement
struct GreekElement: Decodable {
    let _BETA: String?
    let _unicode: String?
    let _translit: String?
}

// MARK: - Pronunciation
struct Pronunciation: Decodable {
    let _strongs: String?
}

// MARK: - See
struct See: Decodable {
    let _language: String?
    let _strongs: String?
}
struct Lemma: Codable {
    let lemma: String
    let xlit: String?
    let pron: String?
    let derivation: String?
    let strongs_def: String?
    let translit: String?
    let kjv_def: String?
}

struct StrongNumbers: Codable {
    let lemmas: [String: Lemma]
}
struct StrongsDefReturnModel {
    var definition, word, pronounciation, derivedFrom, alternateDef: String?
}

class AncientLanguageDefinitionParseUtil {
    func hebrewString(_ strongs: String) -> StrongsDefReturnModel {
        if let url = Bundle.main.url(forResource: "hebrew", withExtension: "json") {
            do {
                // 3. Load the data
                let data = try Data(contentsOf: url)
                
                // 4. Decode the JSON into your struct
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode([String: Lemma].self, from: data)
                var newString = strongs
                    while newString.hasPrefix("/") && newString.count > 1 {
                     newString.removeFirst()
                    
                }
            print(newString)
                for (key, lemma) in jsonData {
                    if key == newString {
                        print(lemma.lemma, lemma.strongs_def)
                        
                        
                        return StrongsDefReturnModel(definition: lemma.strongs_def, word: lemma.lemma, pronounciation: lemma.pron, alternateDef: lemma.kjv_def)

                        
                        
                    }
                 
                   
                }
                print(jsonData.count)
                
            } catch {
                print(error)
                return StrongsDefReturnModel()

                
            }
        }
            else {
                print("Error")
            }
        return StrongsDefReturnModel(word: "")

        
        
        
    }
    func greekString(_ strongs: String) -> StrongsDefReturnModel {
        if let url = Bundle.main.url(forResource: "greek", withExtension: "json") {
            do {
                // 3. Load the data
                let data = try Data(contentsOf: url)
                
                // 4. Decode the JSON into your struct
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode([String: Lemma].self, from: data)
                
                print("G" + strongs)
                for (key, lemma) in jsonData {
                    if key ==  strongs {
                        print(lemma.strongs_def, lemma.lemma)
                        return StrongsDefReturnModel(definition: lemma.strongs_def, word: lemma.lemma, pronounciation: lemma.translit, alternateDef: lemma.kjv_def)

                    }
                 
                   
                }
                print(jsonData.count)
                
            } catch {
                print(error)
                return StrongsDefReturnModel()

                
            }
        }
            else {
                print("Error")
            }
        return StrongsDefReturnModel()
       
        
        
    }
    
    
    
    
}



struct LangTest: View {
    @State private var GreekParse = AncientLanguageDefinitionParseUtil()
    @State private var Stufff: StrongsDefReturnModel = StrongsDefReturnModel()
    var body: some View {
        List() {
            Text(Stufff.word ?? "")
            Text(Stufff.definition ??  "")
            
            
        }
        Text("").onAppear {
            Stufff = GreekParse.hebrewString("489")

        }
    }
}



