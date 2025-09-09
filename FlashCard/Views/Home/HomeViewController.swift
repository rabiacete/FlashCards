import UIKit

final class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let viewModel = HomeViewModel()
    private let background = GradientView()
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let addButton = UIButton(type: .custom)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Flashcards"

        // gradient arka plan
        view.addSubview(background)
        background.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: view.topAnchor),
            background.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            background.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            background.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // table
        tableView.register(DeckCell.self, forCellReuseIdentifier: "DeckCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Floating +
        let cfg = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)
        addButton.setImage(UIImage(systemName: "plus", withConfiguration: cfg), for: .normal)
        addButton.tintColor = .white
        addButton.backgroundColor = .systemBlue
        addButton.layer.cornerRadius = 28
        addButton.layer.masksToBounds = false
        addButton.layer.shadowColor = UIColor.black.cgColor
        addButton.layer.shadowOpacity = 0.22
        addButton.layer.shadowRadius = 12
        addButton.layer.shadowOffset = CGSize(width: 0, height: 8)
        addButton.addTarget(self, action: #selector(addDeckTapped), for: .touchUpInside)

        view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addButton.widthAnchor.constraint(equalToConstant: 56),
            addButton.heightAnchor.constraint(equalToConstant: 56),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
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

    @objc private func addDeckTapped() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        let alert = UIAlertController(title: "Yeni Deste", message: "Adı:", preferredStyle: .alert)
        alert.addTextField()
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        alert.addAction(UIAlertAction(title: "Oluştur", style: .default, handler: { [weak self] _ in
            guard let name = alert.textFields?.first?.text, !name.isEmpty else { return }
            self?.viewModel.addDeck(named: name)
            self?.tableView.reloadData()
        }))
        present(alert, animated: true)
    }

    // MARK: - Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { viewModel.decks.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let deck = viewModel.decks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeckCell", for: indexPath) as! DeckCell
        cell.configure(name: deck.name, count: deck.cards.count)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let deck = viewModel.decks[indexPath.row]
        let vm = DeckDetailViewModel(deck: deck)
        let vc = DeckDetailViewController(viewModel: vm) { [weak self] updated in
            self?.viewModel.update(updated)
            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    // Sağdan sola: Sil
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {
        let del = UIContextualAction(style: .destructive, title: "Sil") { [weak self] _,_,done in
            self?.viewModel.deleteDeck(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            done(true)
        }
        del.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [del])
    }

    // Soldan sağa: Üste sabitle
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {
        let pin = UIContextualAction(style: .normal, title: "Sabitle") { [weak self] _,_,done in
            self?.viewModel.moveDeckToTop(at: indexPath.row)
            tableView.reloadData()
            done(true)
        }
        pin.backgroundColor = .systemOrange
        pin.image = UIImage(systemName: "pin.fill")
        return UISwipeActionsConfiguration(actions: [pin])
    }
}
