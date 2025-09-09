//
//  LocalDeckStore.swift
//  FlashCard
//
//  Created by Rabia Çete on 9.09.2025.
//

// Persistence/LocalDeckStore.swift
import Foundation

final class LocalDeckStore: DeckStore {
    private let fileURL: URL
    private let queue = DispatchQueue(label: "deck.store.queue", qos: .userInitiated)

    init(filename: String = "decks.json") {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.fileURL = dir.appendingPathComponent(filename)
    }

    func loadDecks() throws -> [Deck] {
        if !FileManager.default.fileExists(atPath: fileURL.path) { return [] }
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode([Deck].self, from: data)
    }

    func saveDecks(_ decks: [Deck]) throws {
        let data = try JSONEncoder().encode(decks)
        try data.write(to: fileURL, options: [.atomic])
    }
}

