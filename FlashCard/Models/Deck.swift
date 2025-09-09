//
//  Deck.swift
//  FlashCard
//
//  Created by Rabia Çete on 9.09.2025.
//

// Models/Deck.swift
import Foundation

struct Deck: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var cards: [Card]
    var createdAt: Date

    init(id: UUID = .init(), name: String, cards: [Card] = [], createdAt: Date = .init()) {
        self.id = id
        self.name = name
        self.cards = cards
        self.createdAt = createdAt
    }
}
