//
//  DeckStore.swift
//  FlashCard
//
//  Created by Rabia Çete on 9.09.2025.
//

// Persistence/DeckStore.swift
import Foundation

protocol DeckStore {
    func loadDecks() throws -> [Deck]
    func saveDecks(_ decks: [Deck]) throws
}
