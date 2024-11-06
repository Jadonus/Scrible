//
//  navigationmanager.swift
//  Scrible
//
//  Created by Jadon Gearhart on 7/16/24.
//

import Foundation
class NavigationManager: ObservableObject {
    static let shared = NavigationManager()

    @Published var verse: String?

    func open(coffee: String) {
        DispatchQueue.main.async {
            self.verse = coffee
        }
    }
}
