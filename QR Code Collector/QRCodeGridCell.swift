//
//  QRCodeGridCell.swift
//  QR Code Collector
//

import UIKit

/// Vertical card: icon on top, centered text below.
final class QRCodeGridCell: QRCodeCell {
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override func setupLayout() {
        titleLabel.textAlignment = .center
        // Rows have a fixed height, so long values must truncate instead of growing the cell
        titleLabel.numberOfLines = 3
        titleLabel.lineBreakMode = .byTruncatingTail
        dateLabel.textAlignment = .center

        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(dateLabel)
        stackView.setCustomSpacing(8, after: iconView)
        contentView.addSubview(stackView)

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
        ])
    }
}
