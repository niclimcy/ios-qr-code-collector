//
//  QRCodeCell.swift
//  QR Code Collector
//
//  Created by Nicholas Lim on 28/10/26.
//

import UIKit

enum Style {
    case grid, list

    var cellType: QRCodeCell.Type {
        switch self {
        case .grid: QRCodeGridCell.self
        case .list: QRCodeListCell.self
        }
    }
}

/// Shared card styling, subviews and data binding. Subclasses only arrange the subviews.
class QRCodeCell: UICollectionViewCell {
    class var reuseIdentifier: String { String(describing: self) }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    let iconView: UIImageView = {
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
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentHuggingPriority(.required, for: .vertical)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.required, for: .vertical)
        return imageView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCard()
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

    /// Subclasses override this to add and constrain the shared subviews.
    func setupLayout() {}

    private func setupCard() {
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 12
        contentView.layer.cornerCurve = .continuous
        contentView.layer.borderWidth = 1
        contentView.clipsToBounds = true
        updateBorderColor()
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
