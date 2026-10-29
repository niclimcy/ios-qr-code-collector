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
        stackView.addArrangedSubview(scanLabel)
        stackView.addArrangedSubview(scannedAtLabel)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 24
            ),
            stackView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -24
            ),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            qrImageView.heightAnchor.constraint(equalToConstant: 200),
        ])
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
