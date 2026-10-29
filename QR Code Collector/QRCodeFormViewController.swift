//
//  QRCodeFormViewController.swift
//  QR Code Collector
//
//  Created by Nicholas Lim on 29/10/26.
//

import CoreImage.CIFilterBuiltins
import UIKit

class QRCodeFormViewController: UIViewController {
    let qrCodeItem: QRCodeItem

    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }()

    let qrImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()
    let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    let openButton: UIButton = {
        let button = UIButton()
        var configuration = UIButton.Configuration.prominentGlass()
        configuration.title = "Open"
        configuration.image = UIImage(systemName: "arrow.up.forward.app")
        configuration.imagePadding = 8
        configuration.cornerStyle = .capsule
        button.configuration = configuration
        button.accessibilityHint = "Opens the content of this QR code"
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    let scanLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.text = "Hold another device to scan this code"
        label.numberOfLines = 0
        label.textAlignment = .center

        return label
    }()

    let scannedAtLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center

        return label
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(with qrCodeItem: QRCodeItem) {
        self.qrCodeItem = qrCodeItem
        super.init(nibName: nil, bundle: nil)
        self.valueLabel.text = qrCodeItem.value
        self.scannedAtLabel.text =
            "Scanned \(qrCodeItem.scannedAt.formatted())"
        self.qrImageView.image = self.makeQRCode(from: qrCodeItem.value)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Scan Again"
        view.addSubview(stackView)
        stackView.addArrangedSubview(qrImageView)
        stackView.addArrangedSubview(valueLabel)
        stackView.addArrangedSubview(openButton)
        stackView.addArrangedSubview(scanLabel)
        stackView.addArrangedSubview(scannedAtLabel)

        // Only offer "Open" when the QR code's value is something we can open.
        openButton.isHidden = openableURL == nil
        openButton.addTarget(
            self,
            action: #selector(openTapped),
            for: .touchUpInside
        )

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
    }

    /// Padding between the stack view and the edges of the safe area.
    private let contentPadding: CGFloat = 24

    private func setupLayout() {
        // The QR image is up to 200pt tall, but is the first thing to shrink
        // (before any text) if the sheet is ever short on space.
        qrImageView.setContentCompressionResistancePriority(
            .defaultLow,
            for: .vertical
        )

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: contentPadding
            ),
            stackView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -contentPadding
            ),
            stackView.topAnchor.constraint(
                greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor,
                constant: contentPadding
            ),
            stackView.bottomAnchor.constraint(
                lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -contentPadding
            ),
            stackView.centerYAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.centerYAnchor
            ),
            qrImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 200),
        ])
    }

    /// Height of the content below the navigation bar at the given width.
    func fittingHeight(forWidth width: CGFloat) -> CGFloat {
        loadViewIfNeeded()
        let size = stackView.systemLayoutSizeFitting(
            CGSize(width: width - contentPadding * 2, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return ceil(size.height) + contentPadding * 2
    }

    private func makeQRCode(from string: String, scale: CGFloat = 10)
        -> UIImage?
    {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"

        guard
            let output = filter.outputImage?
                .transformed(by: CGAffineTransform(scaleX: scale, y: scale)),
            let cgImage = CIContext().createCGImage(output, from: output.extent)
        else { return nil }

        return UIImage(cgImage: cgImage)
    }

    /// URL schemes the system can open without extra Info.plist configuration.
    private static let supportedSchemes: Set<String> = [
        "http", "https", "mailto", "tel", "sms", "facetime", "maps",
    ]

    /// The URL represented by the QR code's value, or `nil` if it can't be opened.
    private var openableURL: URL? {
        let value = qrCodeItem.value.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        // Values that already have a supported scheme, e.g. "https://…" or "tel:…".
        if let url = URL(string: value),
            let scheme = url.scheme?.lowercased(),
            Self.supportedSchemes.contains(scheme)
        {
            return url
        }

        // Bare links such as "apple.com" — only if the whole value is the link.
        guard
            let detector = try? NSDataDetector(
                types: NSTextCheckingResult.CheckingType.link.rawValue
            ),
            let match = detector.firstMatch(
                in: value,
                range: NSRange(value.startIndex..., in: value)
            ),
            match.range.length == (value as NSString).length,
            let url = match.url,
            let scheme = url.scheme?.lowercased(),
            Self.supportedSchemes.contains(scheme)
        else { return nil }

        return url
    }

    @objc private func openTapped() {
        guard let url = openableURL else { return }

        UIApplication.shared.open(url) { [weak self] success in
            guard !success else { return }
            let alert = UIAlertController(
                title: "Unable to Open",
                message: "No app is available to open this QR code.",
                preferredStyle: .alert
            )
            alert.addAction(.init(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }

    @objc private func cancelTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}

#Preview {
    UINavigationController(
        rootViewController: QRCodeFormViewController(
            with: QRCodeItem(
                value: "WIFI:T:WPA;S:MyNetwork;P:password123;;",
                scannedAt: Date.now
            )
        )
    )
}
