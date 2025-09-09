//
//  DeckDetailViewModel.swift
//  FlashCard
//
//  Created by Rabia Çete on 9.09.2025.
//

// ViewModels/DeckDetailViewModel.swift
import Foundation

final class DeckDetailViewModel {
    private let store: DeckStore
    private(set) var deck: Deck {
        didSet { persist() }
    }

    init(deck: Deck, store: DeckStore = LocalDeckStore()) {
        self.deck = deck
        self.store = store
    }

    var cards: [Card] { deck.cards }

    func addCard(front: String, back: String, sentence: String?) {
        deck.cards.append(Card(front: front, back: back, sampleSentence: sentence))
    }

    func deleteCard(at index: Int) { deck.cards.remove(at: index) }

    func toggleEdit(card: Card, newFront: String, newBack: String, sentence: String?) {
        guard let i = deck.cards.firstIndex(of: card) else { return }
        deck.cards[i].front = newFront
        deck.cards[i].back = newBack
        deck.cards[i].sampleSentence = sentence
    }

    private func persist() {
        // tüm desteleri yükle → bu desteyi güncelle → kaydet
        var all = (try? store.loadDecks()) ?? []
        if let i = all.firstIndex(where: { $0.id == deck.id }) { all[i] = deck }
        try? store.saveDecks(all)
    }
}
