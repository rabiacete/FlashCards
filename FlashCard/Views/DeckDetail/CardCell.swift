//
//  CardCell.swift
//  FlashCard
//
//  Created by Rabia Çete on 9.09.2025.
//

import UIKit

protocol CardCellDelegate: AnyObject {
    func cardCellDidTapEdit(_ cell: CardCell, id: UUID)
    func cardCellDidTapDelete(_ cell: CardCell, id: UUID)
}

final class CardCell: UITableViewCell {

    weak var delegate: CardCellDelegate?
    private var cardId: UUID?

    private let container = UIView()
    private let frontLabel = UILabel()
    private let arrow = UIImageView()

    // yeni: aksiyon butonları
    private let editBtn: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "pencil"), for: .normal)
        b.tintColor = .systemBlue
        b.widthAnchor.constraint(equalToConstant: 28).isActive = true
        b.heightAnchor.constraint(equalToConstant: 28).isActive = true
        return b
    }()
    private let deleteBtn: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "trash"), for: .normal)
        b.tintColor = .systemRed
        b.widthAnchor.constraint(equalToConstant: 28).isActive = true
        b.heightAnchor.constraint(equalToConstant: 28).isActive = true
        return b
    }()

    private let divider = UIView()
    private let backLabel = UILabel()
    private let sentenceLabel = UILabel()
    private let detailStack = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 16
        container.layer.masksToBounds = false
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.06
        container.layer.shadowRadius = 8
        container.layer.shadowOffset = CGSize(width: 0, height: 4)

        contentView.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])

        frontLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        frontLabel.textColor = .label
        frontLabel.numberOfLines = 0

        arrow.image = UIImage(systemName: "chevron.down")
        arrow.tintColor = .tertiaryLabel
        arrow.setContentCompressionResistancePriority(.required, for: .horizontal)

        editBtn.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        deleteBtn.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)

        // başlık satırı: [front] ---- [edit, delete, arrow]
        let trailingStack = UIStackView(arrangedSubviews: [editBtn, deleteBtn, arrow])
        trailingStack.axis = .horizontal
        trailingStack.alignment = .center
        trailingStack.spacing = 6

        let header = UIStackView(arrangedSubviews: [frontLabel, UIView(), trailingStack])
        header.axis = .horizontal
        header.alignment = .center
        header.spacing = 8

        divider.backgroundColor = .separator
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true

        backLabel.font = .systemFont(ofSize: 16)
        backLabel.textColor = .secondaryLabel
        backLabel.numberOfLines = 0

        sentenceLabel.font = .italicSystemFont(ofSize: 14)
        sentenceLabel.textColor = .tertiaryLabel
        sentenceLabel.numberOfLines = 0

        detailStack.axis = .vertical
        detailStack.spacing = 6
        detailStack.addArrangedSubview(divider)
        detailStack.addArrangedSubview(backLabel)
        detailStack.addArrangedSubview(sentenceLabel)

        let vstack = UIStackView(arrangedSubviews: [header, detailStack])
        vstack.axis = .vertical
        vstack.spacing = 10

        container.addSubview(vstack)
        vstack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vstack.topAnchor.constraint(equalTo: container.topAnchor, constant: 14),
            vstack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
            vstack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -14),
            vstack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -14)
        ])

        detailStack.isHidden = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func prepareForReuse() {
        super.prepareForReuse()
        cardId = nil
        detailStack.isHidden = true
        backLabel.text = nil
        sentenceLabel.text = nil
        arrow.transform = .identity
    }

    func configure(id: UUID, front: String, back: String, sentence: String?, isExpanded: Bool) {
        cardId = id
        frontLabel.text = front
        backLabel.text = back
        sentenceLabel.text = sentence
        detailStack.isHidden = !isExpanded
        UIView.animate(withDuration: 0.2) {
            self.arrow.transform = isExpanded ? CGAffineTransform(rotationAngle: .pi) : .identity
        }
    }

    @objc private func editTapped() {
        guard let id = cardId else { return }
        delegate?.cardCellDidTapEdit(self, id: id)
    }

    @objc private func deleteTapped() {
        guard let id = cardId else { return }
        delegate?.cardCellDidTapDelete(self, id: id)
    }
}
