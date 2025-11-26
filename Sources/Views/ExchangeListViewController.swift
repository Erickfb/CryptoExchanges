import UIKit

final class ExchangeListViewController: UIViewController {
    private let viewModel: ExchangeListViewModel

    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Search exchanges"
        return controller
    }()

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(ExchangeCell.self, forCellReuseIdentifier: ExchangeCell.identifier)
        table.delegate = self
        table.dataSource = self
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 100
        table.refreshControl = refreshControl
        return table
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return control
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .systemRed
        label.isHidden = true
        return label
    }()

    private lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Retry", for: .normal)
        button.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    init(viewModel: ExchangeListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        observeViewModel()
        loadData()
    }

    private func setupUI() {
        title = "Crypto Exchanges"
        view.backgroundColor = .systemBackground

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(errorLabel)
        view.addSubview(retryButton)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 20),
            retryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func observeViewModel() {
        viewModel.$state.addObserver { [weak self] state in
            DispatchQueue.main.async {
                self?.updateUI(for: state)
            }
        }

        viewModel.$exchanges.addObserver { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }

    private func updateUI(for state: LoadingState) {
        switch state {
        case .idle:
            loadingIndicator.stopAnimating()
            errorLabel.isHidden = true
            retryButton.isHidden = true

        case .loading:
            loadingIndicator.startAnimating()
            errorLabel.isHidden = true
            retryButton.isHidden = true
            tableView.isHidden = true

        case .loaded:
            loadingIndicator.stopAnimating()
            errorLabel.isHidden = true
            retryButton.isHidden = true
            tableView.isHidden = false

        case .error(let message):
            loadingIndicator.stopAnimating()
            errorLabel.text = message
            errorLabel.isHidden = false
            retryButton.isHidden = false
            tableView.isHidden = true
        }
    }

    private func loadData() {
        Task {
            await viewModel.loadExchanges()
        }
    }

    @objc private func retryTapped() {
        loadData()
    }

    @objc private func handleRefresh() {
        Task {
            await viewModel.loadExchanges()
            refreshControl.endRefreshing()
        }
    }
}

extension ExchangeListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfExchanges
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ExchangeCell.identifier,
            for: indexPath
        ) as? ExchangeCell,
              let exchange = viewModel.exchange(at: indexPath.row) else {
            return UITableViewCell()
        }

        cell.configure(with: exchange)
        return cell
    }
}

extension ExchangeListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let exchange = viewModel.exchange(at: indexPath.row) else {
            print("❌ Failed to get exchange at index \(indexPath.row)")
            return
        }

        print("✅ Selected exchange: \(exchange.name)")
        viewModel.didSelectExchange(exchange)
    }
}

extension ExchangeListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        viewModel.filterExchanges(with: searchText)
    }
}
