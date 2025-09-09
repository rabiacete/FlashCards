//
//  HomeViewModel.swift
//  FlashCard
//
//  Created by Rabia Çete on 9.09.2025.
//

import Foundation

final class HomeViewModel {
    private let store: DeckStore
    @Published private(set) var decks: [Deck] = []

    init(store: DeckStore = LocalDeckStore()) {
        self.store = store
        load()
    }

    func load() {
        do { decks = try store.loadDecks() }
        catch { decks = [] }
    }

    func addDeck(named name: String) {
        var all = decks
        all.append(Deck(name: name))
        decks = all
        persist()
    }

    func deleteDeck(at index: Int) {
        guard decks.indices.contains(index) else { return }
        decks.remove(at: index)
        persist()
    }

    func update(_ deck: Deck) {
        if let i = decks.firstIndex(where: { $0.id == deck.id }) {
            decks[i] = deck
            persist()
        }
    }

    // <- yeni: soldan sağa kaydırınca üste taşı
    func moveDeckToTop(at index: Int) {
        guard decks.indices.contains(index) else { return }
        let item = decks.remove(at: index)
        decks.insert(item, at: 0)
        persist()
    }

    private func persist() {
        try? store.saveDecks(decks)
    }
}
