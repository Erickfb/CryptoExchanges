import UIKit

final class ExchangeCell: UITableViewCell {
    static let identifier = "ExchangeCell"

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
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        return label
    }()

    private lazy var volumeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .tertiaryLabel
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(logoImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(volumeLabel)
        contentView.addSubview(dateLabel)

        NSLayoutConstraint.activate([
            logoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            logoImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 50),
            logoImageView.heightAnchor.constraint(equalToConstant: 50),

            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            volumeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            volumeLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            volumeLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),

            dateLabel.topAnchor.constraint(equalTo: volumeLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    func configure(with exchange: Exchange) {
        nameLabel.text = exchange.name

        if let volume = exchange.spotVolumeUSD {
            volumeLabel.text = "Volume: \(FormatHelper.formatCurrency(volume))"
        } else {
            volumeLabel.text = "Volume: N/A"
        }

        if let dateLaunched = exchange.dateLaunched {
            dateLabel.text = "Lançamento: \(FormatHelper.formatDate(dateLaunched, style: .short))"
        } else {
            dateLabel.text = "Lançamento: N/A"
        }

        if let logoURL = exchange.logo, let url = URL(string: logoURL) {
            ImageLoader.shared.loadImage(from: url, into: logoImageView)
            logoImageView.backgroundColor = .systemGray6
        } else {
            logoImageView.image = UIImage(systemName: "building.columns.fill")
            logoImageView.tintColor = .systemBlue
            logoImageView.backgroundColor = .clear
        }
    }


    override func prepareForReuse() {
        super.prepareForReuse()
        logoImageView.image = nil
        nameLabel.text = nil
        volumeLabel.text = nil
        dateLabel.text = nil
    }
}
