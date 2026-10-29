//
//  QRCodeCell.swift
//  QR Code Collector
//
//  Created by Nicholas Lim on 28/10/26.
//

import UIKit

class QRCodeCell: UICollectionViewCell {
    static let reuseIdentifier = "QRCodeCell"

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    private let iconView: UIImageView = {
        let configuration = UIImage.SymbolConfiguration(
            pointSize: 28,
            weight: .regular
        )
        let imageView = UIImageView(
            image: UIImage(
                systemName: "qrcode",
                withConfiguration: configuration
            )
        )
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()

        // CGColor doesn't adapt automatically, so refresh the border on appearance changes
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) {
            (self: Self, _: UITraitCollection) in
            self.updateBorderColor()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.cornerCurve = .continuous
        contentView.layer.borderWidth = 1
        contentView.clipsToBounds = true
        updateBorderColor()

        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(dateLabel)
        stackView.setCustomSpacing(8, after: iconView)

        contentView.addSubview(stackView)
    }

    private func setupLayout() {
        // Lower priority so a fixed item size doesn't cause conflicts,
        // while still letting the cell self-size its height when supported.
        let bottomConstraint = stackView.bottomAnchor.constraint(
            equalTo: contentView.bottomAnchor,
            constant: -16
        )
        bottomConstraint.priority = .defaultHigh

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 24
            ),
            stackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 12
            ),
            stackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -12
            ),
            stackView.bottomAnchor.constraint(
                lessThanOrEqualTo: contentView.bottomAnchor,
                constant: -16
            ),
            bottomConstraint,

            titleLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            dateLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor),
        ])
    }

    private func updateBorderColor() {
        contentView.layer.borderColor =
            UIColor.systemGray5
            .resolvedColor(with: traitCollection).cgColor
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        dateLabel.text = nil
    }

    func configure(with item: QRCodeItem) {
        titleLabel.text = item.value
        dateLabel.text = Self.dateFormatter.string(from: item.scannedAt)
    }
}

#Preview {
    let viewController = ViewController()
    viewController.loadViewIfNeeded()
    viewController.applySnapshot(
        items: [
            QRCodeItem(value: "https://www.apple.com", scannedAt: Date.now),
            QRCodeItem(
                value: "WIFI:T:WPA;S:MyNetwork;P:password123;;",
                scannedAt: Date.now
            ),
            QRCodeItem(value: "mailto:hello@example.com", scannedAt: Date.now),
            QRCodeItem(value: "tel:+1234567890", scannedAt: Date.now),
        ],
        animatingDifferences: false
    )
    return viewController
}
