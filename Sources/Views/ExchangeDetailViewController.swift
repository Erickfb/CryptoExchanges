import UIKit

final class ExchangeDetailViewController: UIViewController {
    let viewModel: ExchangeDetailViewModel
    private var isDescriptionExpanded = false
    private var fullDescription = ""

    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemGray6
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 0
        return label
    }()

    private lazy var idLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var descriptionButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "Ver descrição"
        config.image = UIImage(systemName: "text.alignleft")
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.baseForegroundColor = .systemBlue
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)

        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentHorizontalAlignment = .leading
        button.addTarget(self, action: #selector(descriptionTapped), for: .touchUpInside)
        return button
    }()

    private lazy var websiteButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Visitar Website"
        config.image = UIImage(systemName: "safari")
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)

        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(websiteTapped), for: .touchUpInside)
        return button
    }()

    private lazy var feesStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 16
        return stack
    }()

    private lazy var dateLaunchedLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var assetsHeaderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.text = "Moedas"
        return label
    }()

    private lazy var assetsLoadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Buscar moedas"
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        return searchBar
    }()

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(AssetCell.self, forCellReuseIdentifier: AssetCell.identifier)
        table.delegate = self
        table.dataSource = self
        table.isScrollEnabled = false
        table.estimatedRowHeight = 60
        table.rowHeight = UITableView.automaticDimension
        return table
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private var tableHeightConstraint: NSLayoutConstraint?
    private var descriptionHeightConstraint: NSLayoutConstraint?

    init(viewModel: ExchangeDetailViewModel) {
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
        title = viewModel.exchangeName
        view.backgroundColor = .systemBackground

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(logoImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(idLabel)
        contentView.addSubview(descriptionButton)
        contentView.addSubview(websiteButton)
        contentView.addSubview(feesStackView)
        contentView.addSubview(dateLaunchedLabel)
        contentView.addSubview(assetsHeaderLabel)
        contentView.addSubview(searchBar)
        contentView.addSubview(tableView)
        contentView.addSubview(loadingIndicator)
        contentView.addSubview(assetsLoadingIndicator)

        setupFeeViews()

        tableHeightConstraint = tableView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
        tableHeightConstraint?.priority = .defaultHigh
        tableHeightConstraint?.isActive = true

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 80),
            logoImageView.heightAnchor.constraint(equalToConstant: 80),

            nameLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            idLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            idLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            idLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),

            descriptionButton.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 16),
            descriptionButton.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionButton.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),

            websiteButton.topAnchor.constraint(equalTo: descriptionButton.bottomAnchor, constant: 12),
            websiteButton.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            feesStackView.topAnchor.constraint(equalTo: websiteButton.bottomAnchor, constant: 20),
            feesStackView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            feesStackView.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),

            dateLaunchedLabel.topAnchor.constraint(equalTo: feesStackView.bottomAnchor, constant: 16),
            dateLaunchedLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            dateLaunchedLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),

            assetsHeaderLabel.topAnchor.constraint(equalTo: dateLaunchedLabel.bottomAnchor, constant: 24),
            assetsHeaderLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            assetsHeaderLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),

            searchBar.topAnchor.constraint(equalTo: assetsHeaderLabel.bottomAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            contentView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            assetsLoadingIndicator.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            assetsLoadingIndicator.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])

        configureView()
    }

    private func setupFeeViews() {
        let makerFeeView = createFeeView(title: "Maker Fee")
        let takerFeeView = createFeeView(title: "Taker Fee")

        feesStackView.addArrangedSubview(makerFeeView)
        feesStackView.addArrangedSubview(takerFeeView)
    }

    private func createFeeView(title: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemGray6
        container.layer.cornerRadius = 8

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .secondaryLabel

        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        valueLabel.tag = title == "Maker Fee" ? 100 : 101

        container.addSubview(titleLabel)
        container.addSubview(valueLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),

            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])

        return container
    }

    private func configureView() {
        nameLabel.text = viewModel.exchangeName
        idLabel.text = "ID: \(viewModel.exchangeId)"

        if let description = viewModel.exchangeDescription {
            fullDescription = description
            descriptionButton.isHidden = false
        } else {
            descriptionButton.isHidden = true
        }

        if let makerFee = viewModel.makerFee {
            if let label = feesStackView.arrangedSubviews.first?.viewWithTag(100) as? UILabel {
                label.text = String(format: "%.2f%%", makerFee * 100)
            }
        }

        if let takerFee = viewModel.takerFee {
            if let label = feesStackView.arrangedSubviews.last?.viewWithTag(101) as? UILabel {
                label.text = String(format: "%.2f%%", takerFee * 100)
            }
        }

        if let dateLaunched = viewModel.dateLaunched {
            dateLaunchedLabel.text = "Launched: \(FormatHelper.formatDate(dateLaunched))"
        }

        websiteButton.isHidden = viewModel.websiteURL == nil

        if let logoURL = viewModel.exchangeLogo, let url = URL(string: logoURL) {
            ImageLoader.shared.loadImage(from: url, into: logoImageView)
        }
    }


    private func observeViewModel() {
        viewModel.$exchangeInfo.addObserver { [weak self] _ in
            DispatchQueue.main.async {
                self?.configureView()
            }
        }

        viewModel.$assets.addObserver { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self?.updateTableHeight()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self?.updateTableHeight()
                    }
                }
            }
        }

        viewModel.$isLoadingAssets.addObserver { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self?.assetsLoadingIndicator.startAnimating()
                    self?.tableView.isHidden = true
                } else {
                    self?.assetsLoadingIndicator.stopAnimating()
                    self?.tableView.isHidden = false
                }
            }
        }

        viewModel.$state.addObserver { [weak self] state in
            DispatchQueue.main.async {
                switch state {
                case .loading:
                    self?.loadingIndicator.startAnimating()
                    self?.scrollView.isHidden = true
                case .loaded, .error:
                    self?.loadingIndicator.stopAnimating()
                    self?.scrollView.isHidden = false
                default:
                    break
                }
            }
        }
    }

    private func updateTableHeight() {
        view.layoutIfNeeded()
        tableView.layoutIfNeeded()

        let numberOfRows = viewModel.numberOfAssets
        var totalHeight: CGFloat = 0

        for row in 0..<numberOfRows {
            let indexPath = IndexPath(row: row, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) {
                totalHeight += cell.bounds.height
            } else {
                totalHeight += 60
            }
        }

        tableHeightConstraint?.constant = totalHeight

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    private func loadData() {
        Task {
            await viewModel.loadAssets()
        }
    }

    @objc private func descriptionTapped() {
        let modal = DescriptionModalViewController(description: fullDescription)
        present(modal, animated: true)
    }

    @objc private func websiteTapped() {
        guard let urlString = viewModel.websiteURL,
              let url = URL(string: urlString) else {
            return
        }
        UIApplication.shared.open(url)
    }
}

extension ExchangeDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfAssets
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: AssetCell.identifier,
            for: indexPath
        ) as? AssetCell,
              let asset = viewModel.asset(at: indexPath.row) else {
            return UITableViewCell()
        }

        cell.configure(with: asset)
        return cell
    }
}

extension ExchangeDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.numberOfAssets - 1 {
            DispatchQueue.main.async {
                self.updateTableHeight()
            }
        }
    }
}

extension ExchangeDetailViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filterAssets(with: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

