//
//  CardEditorView.swift
//  FlashCard
//
//  Created by Rabia Çete on 9.09.2025.
//

import UIKit

final class CardEditorView: UIView {
    let frontTF = UITextField()
    let backTF = UITextField()
    let sentenceTF = UITextField()
    let saveButton = PrimaryButton(title: "Kelimeyi Kaydet")

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        layer.cornerRadius = 16
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 0, height: 6)

        [frontTF, backTF, sentenceTF].forEach {
            $0.borderStyle = .none
            $0.backgroundColor = .secondarySystemBackground
            $0.layer.cornerRadius = 12
            $0.leftView = UIView(frame: .init(x: 0, y: 0, width: 12, height: 44))
            $0.leftViewMode = .always
            $0.heightAnchor.constraint(equalToConstant: 44).isActive = true
        }
        frontTF.placeholder = "Ön Yüz"
        backTF.placeholder = "Arka Yüz"
        sentenceTF.placeholder = "Örnek Cümle (opsiyonel)"

        let stack = UIStackView(arrangedSubviews: [frontTF, backTF, sentenceTF, saveButton])
        stack.axis = .vertical
        stack.spacing = 10

        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func clear() {
        frontTF.text = nil
        backTF.text = nil
        sentenceTF.text = nil
    }
}
