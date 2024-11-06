import SwiftUI
import Foundation
var books = [
    "Genesis",
    "Exodus",
    "Leviticus",
    "Numbers",
    "Deuteronomy",
    "Joshua",
    "Judges",
    "Ruth",
    "1 Samuel",
    "2 Samuel",
    "1 Kings",
    "2 Kings",
    "1 Chronicles",
    "2 Chronicles",
    "Ezra",
    "Nehemiah",
    "Esther",
    "Job",
    "Psalms",
    "Proverbs",
    "Ecclesiastes",
    "Song of Solomon",
    "Isaiah",
    "Jeremiah",
    "Lamentations",
    "Ezekiel",
    "Daniel",
    "Hosea",
    "Joel",
    "Amos",
    "Obadiah",
    "Jonah",
    "Micah",
    "Nahum",
    "Habakkuk",
    "Zephaniah",
    "Haggai",
    "Zechariah",
    "Malachi",
    "Matthew",
    "Mark",
    "Luke",
    "John",
    "Acts",
    "Romans",
    "1 Corinthians",
    "2 Corinthians",
    "Galatians",
    "Ephesians",
    "Philippians",
    "Colossians",
    "1 Thessalonians",
    "2 Thessalonians",
    "1 Timothy",
    "2 Timothy",
    "Titus",
    "Philemon",
    "Hebrews",
    "James",
    "1 Peter",
    "2 Peter",
    "1 John",
    "2 John",
    "3 John",
    "Jude",
    "Revelation"
]
struct Book: Decodable, Hashable {
    let id: Int
    let name: String
    let testament: String
}
struct Dictionairy {
    let topic, definition, lexeme, transliteration: String
    let pronunciation: String
    let weight: Int
    let shortDefinition: String
}
struct BibleSearchApiModel: Decodable, Hashable {
    let book: Book
    let chapterId: Int
    let verseId: Int
    let verse: String
}

struct BibleApiModel: Decodable {
    let id: Int
    let book: Book
    let chapterId: Int
    let verseId: Int
    let verse: String
}

struct UnfilteredSearchReturn: Decodable {
    let items: [BibleSearchApiModel]?
    let total: Int?
}

struct HebrewGreekApi: Decodable {
    let verse, text: String
}
struct HebrewDictionaryElement: Decodable {
    let headword, parentLexicon: String?
    let Contentt: Contentt
    let strongNumber, transliteration, pronunciation, languageCode: String?
    let parentLexiconDetails: ParentLexiconDetails?
    let rid: String?
    let strongNumbers: [String]?
    let nextHw, prevHw: String?
    let root: Bool?
    let quotes: [String]?
    let gk, twot: [String]?
    let allCited: Bool?
}

// MARK: - Contentt
struct Contentt: Decodable {
    let morphology: String?
    let senses: [ContenttSense]
}

// MARK: - ContenttSense
struct ContenttSense: Decodable {
    let definition: String?
    let senses: [PurpleSense]?
    let grammar: Grammar?
    let form, num: String?
}

// MARK: - Grammar
struct Grammar: Decodable {
    let verbalStem: String?
}

// MARK: - PurpleSense
struct PurpleSense: Decodable {
    let senses: [FluffySense]?
    let grammar: Grammar?
    let definition, num: String?
}

// MARK: - FluffySense
struct FluffySense: Decodable {
    let definition: String?
    let senses: [TentacledSense]?
    let num: String?
}

// MARK: - TentacledSense
struct TentacledSense: Decodable {
    let definition: String?
}

// MARK: - ParentLexiconDetails
struct ParentLexiconDetails: Decodable {
    let name, language, toLanguage: String
    let textCategories: [String]
    let source: String
    let sourceURL: String?
    let attribution: String
    let attributionURL: String?
    let indexTitle, versionTitle, versionLang: String?
    let shouldAutocomplete: Bool?
}
func getSearchResults(query: String, completion: @escaping (UnfilteredSearchReturn?) -> Void) {
    let baseURL = "https://bible-go-api.rkeplin.com/v1/search"
    let translation = "web"
    
    // Construct the full URL
    guard var urlComponents = URLComponents(string: baseURL) else {
        fatalError("Invalid URL")
    }
    
    urlComponents.queryItems = [
        URLQueryItem(name: "query", value: query),
        URLQueryItem(name: "translation", value: translation)
    ]
    
    guard let url = urlComponents.url else {
        fatalError("Could not construct URL")
    }
    
    print(url)
    
    // Create the request
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    // Start a URLSession data task
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        // Handle errors
        if let error = error {
            print("Error: \(error.localizedDescription)")
            completion(nil)
            return
        }
        
        // Handle the response
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            print("Invalid response")
            completion(nil)
            return
        }
        
        // Parse the data
        if let data = data {
            do {
                // Assuming the response is JSON
                let jsonResponse = try JSONDecoder().decode(UnfilteredSearchReturn.self, from: data)
                if let re = jsonResponse.items {
                    completion(jsonResponse)

                }
                else {
                print("sucks to suck")
                }
            } catch {
                print("Failed to parse JSON: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    // Start the task
    task.resume()
}

func getChapter(chapter: Int, book: String, completion: @escaping (VersereturnModel) -> Void) {
    guard let bookNum = books.firstIndex(of: book).map({ $0 + 1 }) else {
        completion(VersereturnModel(verses: ["error"], reference: "", notes: [""], indicesWithNotes: []))
        return
    }
    
    guard let url = URL(string: "https://bible-go-api.rkeplin.com/v1/books/\(bookNum)/chapters/\(chapter)?translation=web") else {
        completion(VersereturnModel(verses: ["error"], reference: "", notes: [""], indicesWithNotes: []))
        return
    }
    
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        if let error = error {
            completion(VersereturnModel(verses: ["error"], reference: "", notes: [""], indicesWithNotes: []))
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            completion(VersereturnModel(verses: ["error"], reference: "", notes: [""], indicesWithNotes: []))
            return
        }
        
        guard let data = data else {
            completion(VersereturnModel(verses: ["error"], reference: "", notes: [""], indicesWithNotes: []))
            return
        }
        
        do {
            let bibleApiModels = try JSONDecoder().decode([BibleApiModel].self, from: data)
            var attributedArray: [String] = []
            var bracketsContentt = [String]()
            var inWithBracks:[Int] = []
            for model in bibleApiModels {
                let verseWithBracketsRemoved = removeBrackets(from: model.verse, bracketsContentt: &bracketsContentt, indexesWithBrackets: &inWithBracks)
                
                
                attributedArray.append(verseWithBracketsRemoved)
            }
            print("STUFF ",inWithBracks, bracketsContentt)
            completion(VersereturnModel(verses: attributedArray, reference: "\(book) \(chapter)", notes: bracketsContentt, indicesWithNotes: inWithBracks))
        } catch {
            completion(VersereturnModel(verses: [], reference: "\(book) \(chapter)", notes: [], indicesWithNotes: []))
        }
    }
    
    task.resume()
}
struct VerseApii: Codable {
    let reference: String
    let text: String
    let translation_id: String
    let translation_name: String
    let translation_note: String
}



func getVerse(_ ref: String, completion: @escaping (String) -> Void) {
  print(ref)
    
    guard let url = URL(string: "https://bible-api.com/\(ref)") else {
        completion("fund")
        return
    }
    
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        if let error = error {
            completion("fund")
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            completion("fun")
            return
        }
        
        guard let data = data else {
            completion("ges")
            return
        }
        print(url)
        print("RA",String(data: data, encoding: .utf8))
        do {
            let bibleApiModels = try JSONDecoder().decode(VerseApii.self, from: data)
           print(bibleApiModels.text)
            completion(bibleApiModels.text)
        } catch {
            print(error)
            completion(error.localizedDescription)
        }
    }
    
    task.resume()
}
var index = 0

func removeBrackets(from text: String, bracketsContentt: inout [String], indexesWithBrackets: inout [Int]) -> String {
    var result = ""
    var currentBracketContentt = ""
    var insideBrackets = false
    for char in text.indices {
        if text[char] == "{" {
            insideBrackets = true
            currentBracketContentt = ""
        } else if text[char] == "}" {
            insideBrackets = false
            bracketsContentt.append(currentBracketContentt)
            indexesWithBrackets.append(index)
            
        } else if insideBrackets {
            currentBracketContentt.append(text[char])

        } else {
            result.append(text[char])
        }
    }
    index += 1

    return result
}
struct VersereturnModel: Hashable {
    let verses:[String]
    let reference: String
    let notes: [String]
    let indicesWithNotes: [Int]
    func splitAtMidpoint() -> (VersereturnModel, VersereturnModel)? {
           guard verses.count > 0 else {
               return nil // Handle case where verses array is empty
           }
           
           let midpoint = verses.count / 2
           
           // Ensure midpoint is within valid range
           guard midpoint > 0 && midpoint < verses.count else {
               return nil // Handle case where midpoint calculation is invalid
           }
           
           // Split verses
           let firstHalfVerses = Array(verses.prefix(midpoint))
           let secondHalfVerses = Array(verses.suffix(from: midpoint))
           
           // Split notes
           let firstHalfNotes: [String]
           let secondHalfNotes: [String]
           print(notes)
        print(secondHalfVerses)
           
           // Filter indicesWithNotes
        
           
           let firstModel = VersereturnModel(verses: firstHalfVerses,
                                             reference: reference,
                                             notes: notes,
                                             indicesWithNotes: indicesWithNotes)
           
           let secondModel = VersereturnModel(verses: secondHalfVerses,
                                              reference: reference,
                                              notes: notes,
                                              indicesWithNotes: indicesWithNotes)
           
           return (firstModel, secondModel)
       }
   }

// Usage example

