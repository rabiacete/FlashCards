//
//  StudyViewController.swift
//  FlashCard
//
//  Created by Rabia Çete on 9.09.2025.
//

import UIKit

final class StudyViewController: UIViewController {
    private let viewModel: StudyViewModel

    // OPAK arka plan (üst üste binme sorununu çözer)
    private let background = GradientView()

    // Üst sayaç barı
    private let counterBar = UIView()
    private let trueLabel = UILabel()
    private let falseLabel = UILabel()

    // Kart alanı
    private let cardContainer = UIView()
    private let cardView = FlipCardView()

    // Bitti ekranı
    private let finishedView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBackground
        v.layer.cornerRadius = 16
        v.layer.masksToBounds = false
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.12
        v.layer.shadowRadius = 12
        v.layer.shadowOffset = CGSize(width: 0, height: 6)

        let emoji = UILabel()
        emoji.text = "🎉"
        emoji.font = .systemFont(ofSize: 44)
        emoji.textAlignment = .center

        let title = UILabel()
        title.text = "Deste bitti"
        title.font = .systemFont(ofSize: 22, weight: .semibold)
        title.textAlignment = .center
        title.textColor = .label

        let stack = UIStackView(arrangedSubviews: [emoji, title])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center

        v.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: v.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: v.centerYAnchor)
        ])

        v.isHidden = true
        return v
    }()

    private let trueBtn  = PrimaryButton(title: "TRUE ✓", style: .success)
    private let falseBtn = PrimaryButton(title: "FALSE ✗", style: .danger)

    // MARK: - Init
    init(viewModel: StudyViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "✏️ Desteyi Çalış"

        // 1) OPAK GRADIENT ARKA PLAN
        view.addSubview(background)
        background.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: view.topAnchor),
            background.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            background.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            background.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        view.isOpaque = true   // ekstra güvence

        setupCounterBar()

        // Kartı çevirme jesti
        cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flip)))

        trueBtn.addTarget(self, action: #selector(correct), for: .touchUpInside)
        falseBtn.addTarget(self, action: #selector(wrong),   for: .touchUpInside)

        // Alt butonlar
        let buttons = UIStackView(arrangedSubviews: [trueBtn, falseBtn])
        buttons.axis = .horizontal
        buttons.spacing = 16
        buttons.distribution = .fillEqually
        view.addSubview(buttons)
        buttons.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttons.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            buttons.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            buttons.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            buttons.heightAnchor.constraint(greaterThanOrEqualToConstant: 56)
        ])

        view.addSubview(cardContainer)
        cardContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // Üst sayaçtan aşağı taşmayacak garanti
            cardContainer.topAnchor.constraint(greaterThanOrEqualTo: counterBar.bottomAnchor, constant: 16),
            // Alttaki butonlara çarpmayacak garanti
            cardContainer.bottomAnchor.constraint(lessThanOrEqualTo: buttons.topAnchor, constant: -20),

            cardContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),   // tam ekran ortası
            cardContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            cardContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            // Yükseklik cihazla orantılı (orta boy)
            cardContainer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.30)
        ])

        cardContainer.addSubview(cardView)
        cardContainer.addSubview(finishedView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        finishedView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: cardContainer.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: cardContainer.bottomAnchor),

            finishedView.topAnchor.constraint(equalTo: cardContainer.topAnchor),
            finishedView.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor),
            finishedView.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor),
            finishedView.bottomAnchor.constraint(equalTo: cardContainer.bottomAnchor),
        ])

        render()
        refreshCounters()
    }

    // MARK: - UI Pieces
    private func setupCounterBar() {
        counterBar.backgroundColor = .systemBackground.withAlphaComponent(0.85)
        counterBar.layer.cornerRadius = 14
        counterBar.layer.masksToBounds = false
        counterBar.layer.shadowColor = UIColor.black.cgColor
        counterBar.layer.shadowOpacity = 0.10
        counterBar.layer.shadowRadius = 10
        counterBar.layer.shadowOffset = CGSize(width: 0, height: 6)

        view.addSubview(counterBar)
        counterBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            counterBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            counterBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            counterBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            counterBar.heightAnchor.constraint(equalToConstant: 40) // biraz daha ince
        ])

        [trueLabel, falseLabel].forEach {
            $0.font = .systemFont(ofSize: 16, weight: .semibold)
            $0.textColor = .label
            $0.textAlignment = .center
        }

        let stack = UIStackView(arrangedSubviews: [trueLabel, falseLabel])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        counterBar.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: counterBar.topAnchor, constant: 6),
            stack.bottomAnchor.constraint(equalTo: counterBar.bottomAnchor, constant: -6),
            stack.leadingAnchor.constraint(equalTo: counterBar.leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: counterBar.trailingAnchor, constant: -12)
        ])
    }

    private func refreshCounters() {
        trueLabel.text = "True: \(viewModel.learnedCount)"
        falseLabel.text = "False: \(viewModel.wrongCount)"
    }

    private func render() {
        if let c = viewModel.current {
            finishedView.isHidden = true
            cardView.isHidden = false
            trueBtn.isHidden = false
            falseBtn.isHidden = false
            cardView.configure(front: c.front, back: c.back)
        } else {
            cardView.isHidden = true
            finishedView.isHidden = false
            trueBtn.isHidden = true
            falseBtn.isHidden = true
        }
        refreshCounters()
    }

    // MARK: - Actions
    @objc private func flip() {
        guard !viewModel.isFinished else { return }
        viewModel.flip()
        cardView.flip(showFront: viewModel.showingFront)
    }

    @objc private func correct() { advance(correct: true) }
    @objc private func wrong()   { advance(correct: false) }

    private func advance(correct: Bool) {
        viewModel.answer(correct: correct)
        render()
    }
    
    
    // >>> NAV BAR: Başlığı beyaz yap
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let ap = UINavigationBarAppearance()
        ap.configureWithTransparentBackground()        // gradient görünsün
        ap.titleTextAttributes = [.foregroundColor: UIColor.white,
                                  .font: UIFont.systemFont(ofSize: 20, weight: .semibold)]
        ap.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = ap
        navigationController?.navigationBar.scrollEdgeAppearance = ap
        navigationController?.navigationBar.compactAppearance = ap
        navigationController?.navigationBar.tintColor = .white // back/chevron/btn’ler de beyaz
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Diğer ekranlar etkilenmesin diye varsayılanı geri koy
        let ap = UINavigationBarAppearance()
        ap.configureWithDefaultBackground()
        navigationController?.navigationBar.standardAppearance = ap
        navigationController?.navigationBar.scrollEdgeAppearance = ap
        navigationController?.navigationBar.compactAppearance = ap
        navigationController?.navigationBar.tintColor = nil
    }
    // <<< NAV BAR

    
    
}
