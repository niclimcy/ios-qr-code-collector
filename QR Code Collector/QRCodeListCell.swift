//
//  QRCodeListCell.swift
//  QR Code Collector
//

import UIKit

/// Horizontal row: icon on the left, left-aligned text on the right.
final class QRCodeListCell: QRCodeCell {
    private let textStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 4
        return stackView
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override func setupLayout() {
        titleLabel.textAlignment = .natural
        dateLabel.textAlignment = .natural

        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(dateLabel)

        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(textStack)
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 16
            ),
            stackView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16
            ),
            stackView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16
            ),
            stackView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -16
            ),
        ])
    }
}
