//
//  PrimaryButton.swift
//  FlashCard
//
//  Created by Rabia Çete on 9.09.2025.
//
import UIKit

enum PrimaryButtonStyle { case success, danger, normal }

final class PrimaryButton: UIButton {
    private let style: PrimaryButtonStyle

    init(title: String, style: PrimaryButtonStyle = .normal) {
        self.style = style
        super.init(frame: .zero)

        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)

        backgroundColor = {
            switch style {
            case .success: return .systemGreen
            case .danger:  return .systemRed
            case .normal:  return .systemBlue
            }
        }()

        layer.cornerRadius = 14
        layer.masksToBounds = false

        // shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.18
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 6)

        contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 52).isActive = true
    }

    // küçük “press” animasyonu
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.12) {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            }
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
