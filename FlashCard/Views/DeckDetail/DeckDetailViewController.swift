import UIKit

final class DeckDetailViewController: UIViewController,
                                      UITableViewDataSource,
                                      UITableViewDelegate,
                                      CardCellDelegate {

    private let viewModel: DeckDetailViewModel
    private let onSaveDeck: (Deck) -> Void

    private let background = GradientView()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let editor = CardEditorView()
    private var expanded = Set<UUID>()

    // “Çalış” butonu (nav bar)
    private lazy var studyItem: UIBarButtonItem = {
        UIBarButtonItem(title: "✏️Çalış",
                        style: .plain,
                        target: self,
                        action: #selector(studyTapped))
    }()

    // MARK: - Init
    init(viewModel: DeckDetailViewModel, onSaveDeck: @escaping (Deck) -> Void) {
        self.viewModel = viewModel
        self.onSaveDeck = onSaveDeck
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.deck.name

        // Arka plan gradient
        view.addSubview(background)
        background.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: view.topAnchor),
            background.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            background.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            background.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Tablo
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 72
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(CardCell.self, forCellReuseIdentifier: "CardCell")
        tableView.dataSource = self
        tableView.delegate = self

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Header = Editor kartı
        let header = UIView()
        header.backgroundColor = .clear
        header.addSubview(editor)
        editor.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            editor.topAnchor.constraint(equalTo: header.topAnchor, constant: 12),
            editor.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16),
            editor.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -16),
            editor.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -8)
        ])
        tableView.tableHeaderView = header
        layoutTableHeader()

        // Ekleme aksiyonu
        editor.saveButton.addTarget(self, action: #selector(addCard), for: .touchUpInside)

        // Nav item
        navigationItem.rightBarButtonItem = studyItem
        updateRightButtonState()
    }

    // >>> NAV BAR: Başlığı ve butonları beyaz yap
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let ap = UINavigationBarAppearance()
        ap.configureWithTransparentBackground()
        ap.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 20, weight: .semibold)
        ]
        ap.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = ap
        navigationController?.navigationBar.scrollEdgeAppearance = ap
        navigationController?.navigationBar.compactAppearance = ap
        navigationController?.navigationBar.tintColor = .white
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let ap = UINavigationBarAppearance()
        ap.configureWithDefaultBackground()
        navigationController?.navigationBar.standardAppearance = ap
        navigationController?.navigationBar.scrollEdgeAppearance = ap
        navigationController?.navigationBar.compactAppearance = ap
        navigationController?.navigationBar.tintColor = nil
    }
    // <<< NAV BAR

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutTableHeader()
    }

    private func layoutTableHeader() {
        guard let header = tableView.tableHeaderView else { return }
        header.setNeedsLayout(); header.layoutIfNeeded()
        let size = header.systemLayoutSizeFitting(
            CGSize(width: tableView.bounds.width, height: .greatestFiniteMagnitude)
        )
        if header.frame.height != size.height {
            header.frame.size.height = size.height
            tableView.tableHeaderView = header
        }
    }

    // MARK: - Helpers
    private func updateRightButtonState() {
        let empty = viewModel.cards.isEmpty

        // Tıklanabilir kalsın; sadece görsel olarak pasifleştir
        studyItem.isEnabled = true

        // Beyaz başlık stilini bozmayacak şekilde saydamlığını düşür
        let alpha: CGFloat = empty ? 0.45 : 1.0
        studyItem.tintColor = UIColor.white.withAlphaComponent(alpha)

        // Erişilebilirlik ipucu
        studyItem.accessibilityHint = empty
            ? "Çalışmadan önce en az bir kelime eklemelisin."
            : "Desteyi çalıştır."
    }


    private func showEmptyDeckAlert() {
        let ac = UIAlertController(
            title: "Deste boş",
            message: "Çalışmaya başlamadan önce en az bir kelime eklemelisin.",
            preferredStyle: .alert
        )
        ac.addAction(UIAlertAction(title: "Tamam", style: .default, handler: { [weak self] _ in
            // kullanıcıyı ekleme alanına odakla
            self?.tableView.setContentOffset(.zero, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                self?.editor.frontTF.becomeFirstResponder()
            }
        }))
        present(ac, animated: true)
    }

    // MARK: - Actions
    @objc private func addCard() {
        guard let f = editor.frontTF.text, !f.isEmpty,
              let b = editor.backTF.text, !b.isEmpty else { return }

        viewModel.addCard(front: f, back: b, sentence: editor.sentenceTF.text?.nilIfEmpty)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        editor.clear()
        tableView.reloadData()
        onSaveDeck(viewModel.deck)
        updateRightButtonState()
    }

    @objc private func studyTapped() {
        // Boşsa uyar, geçme
        guard !viewModel.cards.isEmpty else {
            showEmptyDeckAlert()
            return
        }
        let vm = StudyViewModel(cards: viewModel.cards)
        let vc = StudyViewController(viewModel: vm)
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.cards.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let card = viewModel.cards[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CardCell", for: indexPath) as! CardCell
        cell.delegate = self
        cell.configure(id: card.id,
                       front: card.front,
                       back: card.back,
                       sentence: card.sampleSentence,
                       isExpanded: expanded.contains(card.id))
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let card = viewModel.cards[indexPath.row]
        if expanded.contains(card.id) { expanded.remove(card.id) } else { expanded.insert(card.id) }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    // Swipe ile silme
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {
        let del = UIContextualAction(style: .destructive, title: "Sil") { [weak self] _,_,done in
            guard let self = self else { return }
            let id = self.viewModel.cards[indexPath.row].id
            self.expanded.remove(id)
            self.viewModel.deleteCard(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.onSaveDeck(self.viewModel.deck)
            self.updateRightButtonState()
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [del])
    }

    // MARK: - CardCellDelegate
    func cardCellDidTapEdit(_ cell: CardCell, id: UUID) {
        guard let idx = viewModel.cards.firstIndex(where: { $0.id == id }) else { return }
        let card = viewModel.cards[idx]

        let ac = UIAlertController(title: "Kartı Düzenle", message: nil, preferredStyle: .alert)
        ac.addTextField { $0.text = card.front; $0.placeholder = "Ön yüz" }
        ac.addTextField { $0.text = card.back;  $0.placeholder = "Arka yüz" }
        ac.addTextField { $0.text = card.sampleSentence; $0.placeholder = "Örnek cümle (ops.)" }
        ac.addAction(UIAlertAction(title: "İptal", style: .cancel))
        ac.addAction(UIAlertAction(title: "Kaydet", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            let f = ac.textFields?[0].text ?? ""
            let b = ac.textFields?[1].text ?? ""
            let s = ac.textFields?[2].text?.nilIfEmpty
            guard !f.isEmpty, !b.isEmpty else { return }
            self.viewModel.toggleEdit(card: card, newFront: f, newBack: b, sentence: s)
            self.onSaveDeck(self.viewModel.deck)
            self.tableView.reloadRows(at: [IndexPath(row: idx, section: 0)], with: .automatic)
        }))
        present(ac, animated: true)
    }

    func cardCellDidTapDelete(_ cell: CardCell, id: UUID) {
        guard let idx = viewModel.cards.firstIndex(where: { $0.id == id }) else { return }
        let ac = UIAlertController(title: "Sil",
                                   message: "Bu kartı desteden silmek istiyor musun?",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "İptal", style: .cancel))
        ac.addAction(UIAlertAction(title: "Sil", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            self.expanded.remove(id)
            self.viewModel.deleteCard(at: idx)
            self.tableView.deleteRows(at: [IndexPath(row: idx, section: 0)], with: .automatic)
            self.onSaveDeck(self.viewModel.deck)
            self.updateRightButtonState()
        }))
        present(ac, animated: true)
    }
}

// küçük yardımcı
private extension String { var nilIfEmpty: String? { isEmpty ? nil : self } }
