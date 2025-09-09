//
//  StudyViewModel.swift
//  FlashCard
//
//  Created by Rabia Çete on 9.09.2025.
//

import Foundation

final class StudyViewModel {
    private(set) var queue: [Card]           // çalışılacak sıra
    private(set) var currentIndex: Int = 0
    private(set) var showingFront = true

    // Sayaçlar
    private(set) var learnedCount: Int = 0           // kalıcı doğruya ulaşılan kart sayısı
    private var wrongMarked = Set<UUID>()            // en az bir kez yanlışlanıp henüz öğrenilmemiş kartlar
    var wrongCount: Int { wrongMarked.count }        // ekranda gösterilecek "False"

    init(cards: [Card]) {
        self.queue = cards.shuffled()
    }

    var current: Card? {
        guard !queue.isEmpty, currentIndex < queue.count else { return nil }
        return queue[currentIndex]
    }

    func flip() { showingFront.toggle() }

    // doğruysa kartı çıkar; yanlışsa kuyruğun sonuna at
    // Sayaç mantığı:
    // - İlk yanlışta wrongMarked'e eklenir (False artar)
    // - Aynı kart daha sonra doğru bilinirse wrongMarked'den çıkar (False azalır), True artar
    func answer(correct: Bool) {
        guard !queue.isEmpty, currentIndex < queue.count else { return }
        let card = queue[currentIndex]

        if correct {
            // Eğer bu kart daha önce yanlışlandıysa False’u azalt
            if wrongMarked.contains(card.id) {
                wrongMarked.remove(card.id)
            }
            // Artık kalıcı olarak öğrenilmiş kabul et
            learnedCount += 1
            queue.remove(at: currentIndex)
        } else {
            // İlk kez yanlışlanıyorsa False’u artır
            if !wrongMarked.contains(card.id) {
                wrongMarked.insert(card.id)
            }
            // Yanlış kart sona atılır
            queue.remove(at: currentIndex)
            queue.append(card)
        }

        showingFront = true
        if currentIndex >= queue.count { currentIndex = 0 }
    }

    var isFinished: Bool { queue.isEmpty }
}
