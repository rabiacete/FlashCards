//
//  FlipCardView.swift
//  FlashCard
//
//  Created by Rabia Çete on 9.09.2025.
//

import UIKit

final class FlipCardView: UIView {
    private let label = UILabel()
    private var frontText = "", backText = ""
    private var showingFront = true

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.12
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 6)

        label.textAlignment = .center
        label.font = .systemFont(ofSize: 28, weight: .semibold)
        label.numberOfLines = 0

        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(front: String, back: String) {
        frontText = front; backText = back
        showingFront = true
        label.text = frontText
        backgroundColor = .white
    }

    func flip(showFront: Bool) {
        showingFront = showFront
        let txt = showFront ? frontText : backText
        let opt: UIView.AnimationOptions = showFront ? .transitionFlipFromLeft : .transitionFlipFromRight
        UIView.transition(with: self, duration: 0.35, options: [opt, .showHideTransitionViews]) {
            self.label.text = txt
        }
    }

    func showFinished() {
        backgroundColor = .systemGreen.withAlphaComponent(0.2)
        label.text = "🎉 Bitti!"
    }
}
