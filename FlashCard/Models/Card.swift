//
//  Card.swift
//  FlashCard
//
//  Created by Rabia Çete on 9.09.2025.
//

// Models/Card.swift
import Foundation

struct Card: Codable, Identifiable, Equatable {
    let id: UUID
    var front: String         // Ön yüz
    var back: String          // Arka yüz
    var sampleSentence: String? // İsteğe bağlı cümle

    init(id: UUID = .init(), front: String, back: String, sampleSentence: String? = nil) {
        self.id = id
        self.front = front
        self.back = back
        self.sampleSentence = sampleSentence
    }
}
