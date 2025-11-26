import UIKit

final class DescriptionModalViewController: UIViewController {
    private let descriptionText: String

    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        return view
    }()

    private lazy var headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Descrição"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()

    private lazy var closeButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "xmark.circle.fill")
        config.baseForegroundColor = .secondaryLabel
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 24)

        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return button
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .separator
        return view
    }()

    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        textView.textContainer.lineFragmentPadding = 0
        textView.showsVerticalScrollIndicator = true
        textView.linkTextAttributes = [
            .foregroundColor: UIColor.systemBlue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        return textView
    }()

    init(description: String) {
        self.descriptionText = description
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureAttributedText()
    }

    private func configureAttributedText() {
        var processedText = descriptionText
        processedText = processedText.replacingOccurrences(of: "\\n", with: "\n")
        processedText = processedText.trimmingCharacters(in: .whitespacesAndNewlines)

        let attributedString = NSMutableAttributedString(string: processedText)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        paragraphStyle.paragraphSpacing = 10

        attributedString.addAttributes([
            .font: UIFont.systemFont(ofSize: 15, weight: .regular),
            .foregroundColor: UIColor.label,
            .paragraphStyle: paragraphStyle
        ], range: NSRange(location: 0, length: attributedString.length))

        applyLinkFormatting(to: attributedString)
        applyHeaderFormatting(to: attributedString)
        applyBoldFormatting(to: attributedString)

        textView.attributedText = attributedString
    }

    private func applyBoldFormatting(to attributedString: NSMutableAttributedString) {
        let boldPattern = "\\*\\*([^\\*]+)\\*\\*"
        guard let regex = try? NSRegularExpression(pattern: boldPattern, options: []) else { return }
        let matches = regex.matches(in: attributedString.string, options: [], range: NSRange(location: 0, length: attributedString.length))

        for match in matches.reversed() {
            if match.numberOfRanges == 2,
               let textRange = Range(match.range(at: 1), in: attributedString.string) {
                let boldText = String(attributedString.string[textRange])
                let replacement = NSAttributedString(
                    string: boldText,
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 15, weight: .semibold),
                        .foregroundColor: UIColor.label
                    ]
                )
                attributedString.replaceCharacters(in: match.range, with: replacement)
            }
        }
    }

    private func applyHeaderFormatting(to attributedString: NSMutableAttributedString) {
        let headerPatterns = [
            ("###\\s*(.+?)($|\\n)", 16, 10, 6),
            ("##\\s*(.+?)($|\\n)", 17, 12, 8),
            ("#\\s*(.+?)($|\\n)", 19, 14, 10)
        ]

        for (pattern, fontSize, spacingBefore, spacingAfter) in headerPatterns {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { continue }
            let matches = regex.matches(in: attributedString.string, options: [], range: NSRange(location: 0, length: attributedString.length))

            for match in matches.reversed() {
                if match.numberOfRanges >= 2,
                   let textRange = Range(match.range(at: 1), in: attributedString.string) {
                    let headerText = String(attributedString.string[textRange]).trimmingCharacters(in: .whitespacesAndNewlines)
                    let headerParagraph = NSMutableParagraphStyle()
                    headerParagraph.paragraphSpacing = CGFloat(spacingAfter)
                    headerParagraph.paragraphSpacingBefore = CGFloat(spacingBefore)

                    let replacement = NSAttributedString(
                        string: headerText + "\n",
                        attributes: [
                            .font: UIFont.systemFont(ofSize: CGFloat(fontSize), weight: .bold),
                            .foregroundColor: UIColor.label,
                            .paragraphStyle: headerParagraph
                        ]
                    )
                    attributedString.replaceCharacters(in: match.range, with: replacement)
                }
            }
        }
    }

    private func applyLinkFormatting(to attributedString: NSMutableAttributedString) {
        let linkPattern = "\\[([^\\]]+)\\]\\(([^\\)]+)\\)"
        if let regex = try? NSRegularExpression(pattern: linkPattern, options: []) {
            let matches = regex.matches(in: attributedString.string, options: [], range: NSRange(location: 0, length: attributedString.length))

            for match in matches.reversed() {
                if match.numberOfRanges == 3,
                   let linkTextRange = Range(match.range(at: 1), in: attributedString.string),
                   let urlRange = Range(match.range(at: 2), in: attributedString.string) {
                    let linkText = String(attributedString.string[linkTextRange])
                    let urlString = String(attributedString.string[urlRange])

                    if let url = URL(string: urlString) {
                        let replacementString = NSAttributedString(
                            string: linkText,
                            attributes: [
                                .link: url,
                                .foregroundColor: UIColor.systemBlue,
                                .underlineStyle: NSUnderlineStyle.single.rawValue
                            ]
                        )
                        attributedString.replaceCharacters(in: match.range, with: replacementString)
                    }
                }
            }
        }

        let urlPattern = "https?://[^\\s]+"
        if let urlRegex = try? NSRegularExpression(pattern: urlPattern, options: []) {
            let matches = urlRegex.matches(in: attributedString.string, options: [], range: NSRange(location: 0, length: attributedString.length))

            for match in matches {
                if let range = Range(match.range, in: attributedString.string) {
                    let urlString = String(attributedString.string[range])
                    if let url = URL(string: urlString) {
                        attributedString.addAttributes([
                            .link: url,
                            .foregroundColor: UIColor.systemBlue,
                            .underlineStyle: NSUnderlineStyle.single.rawValue
                        ], range: match.range)
                    }
                }
            }
        }
    }

    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        view.addSubview(containerView)
        containerView.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(closeButton)
        containerView.addSubview(separatorView)
        containerView.addSubview(textView)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7),

            headerView.topAnchor.constraint(equalTo: containerView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 56),

            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),

            closeButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),

            separatorView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),

            textView.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func backgroundTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        if !containerView.frame.contains(location) {
            dismiss(animated: true)
        }
    }
}
