//
//  BadgeView.swift
//  FlashCard
//
//  Created by Rabia Çete on 9.09.2025.
//
import UIKit

final class BadgeView: UILabel {

    override init(frame: CGRect) { super.init(frame: frame); setup() }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }

    private func setup() {
        textAlignment = .center
        font = .systemFont(ofSize: 12, weight: .bold)
        textColor = .white
        backgroundColor = .systemBlue
        layer.masksToBounds = false

        // gölge
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 6
        layer.shadowOffset = CGSize(width: 0, height: 3)
    }

    // padding + dairesel görünüm
    override var intrinsicContentSize: CGSize {
        let s = super.intrinsicContentSize
        let w = max(24, s.width + 12)
        return CGSize(width: w, height: 24)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
}
