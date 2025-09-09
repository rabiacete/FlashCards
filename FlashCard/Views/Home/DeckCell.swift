//
//  DeckCell.swift
//  FlashCard
//
//  Created by Rabia Çete on 9.09.2025.
//
import UIKit

final class DeckCell: UITableViewCell {

    private let pill = UIView()
    private let nameLabel = UILabel()
    private let countBadge = UILabel()
    private let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))

    // Ölçüler
    private let pillHeight: CGFloat = 56      // daha ince
    private let sideInset: CGFloat = 1      // daha uzun görünüm için kenar boşluğu

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        // BEYAZ PILL
        pill.backgroundColor = .systemBackground
        pill.layer.cornerRadius = 18
        pill.layer.masksToBounds = false
        pill.layer.shadowColor = UIColor.black.cgColor
        pill.layer.shadowOpacity = 0.07     // daha hafif gölge
        pill.layer.shadowRadius = 8
        pill.layer.shadowOffset = CGSize(width: 0, height: 4)

        contentView.addSubview(pill)
        pill.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pill.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            pill.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            pill.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: sideInset),
            pill.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -sideInset),
            pill.heightAnchor.constraint(greaterThanOrEqualToConstant: pillHeight)
        ])

        // BAŞLIK
        nameLabel.font = .systemFont(ofSize: 18)

        // SAYI ROZETİ (küçük ve net)
        countBadge.textAlignment = .center
        countBadge.font = .systemFont(ofSize: 12, weight: .bold)
        countBadge.textColor = .white
        countBadge.backgroundColor = .systemBlue
        countBadge.layer.masksToBounds = true
        countBadge.layer.cornerRadius = 14   // 28x28

        // CHEVRON
        chevron.tintColor = .systemGray3
        chevron.contentMode = .scaleAspectFit

        [nameLabel, countBadge, chevron].forEach { v in
            pill.addSubview(v)
            v.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 16),
            nameLabel.centerYAnchor.constraint(equalTo: pill.centerYAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: countBadge.leadingAnchor, constant: -12),

            chevron.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -14),
            chevron.centerYAnchor.constraint(equalTo: pill.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 12),

            countBadge.centerYAnchor.constraint(equalTo: pill.centerYAnchor),
            countBadge.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -10),
            countBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 28),
            countBadge.heightAnchor.constraint(equalToConstant: 28)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(name: String, count: Int) {
        nameLabel.text = name
        countBadge.text = "\(count)"
        countBadge.isHidden = count == 0
    }
}
