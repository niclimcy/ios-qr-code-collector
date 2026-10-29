//
//  QRScannerViewController.swift
//  QR Code Collector
//
//  Created by Nicholas Lim on 29/10/26.
//

import AVFoundation
import QRScanner
import UIKit

protocol QRScannerViewControllerDelegate: AnyObject {
    func didScanQRCode(_ value: String)
}

class QRScannerViewController: UIViewController {
    weak var delegate: QRScannerViewControllerDelegate?

    private let qrScannerView: QRScannerView = {
        let scannerView = QRScannerView()
        scannerView.translatesAutoresizingMaskIntoConstraints = false
        return scannerView
    }()

    private let flashButton: UIButton = {
        let button = UIButton()
        var configuration = UIButton.Configuration.glass()
        configuration.image = UIImage(systemName: "flashlight.off.fill")
        configuration.preferredSymbolConfigurationForImage =
            UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        configuration.cornerStyle = .capsule
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 16,
            leading: 16,
            bottom: 16,
            trailing: 16
        )
        button.configuration = configuration

        button.configurationUpdateHandler = { button in
            guard var configuration = button.configuration else { return }
            configuration.image = UIImage(
                systemName: button.isSelected
                    ? "flashlight.on.fill" : "flashlight.off.fill"
            )
            button.configuration = configuration
            button.accessibilityValue = button.isSelected ? "On" : "Off"
        }

        button.accessibilityLabel = "Flashlight"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupScannerLayout()
        setupFlashButton()
        setupQRScanner()
    }

    private func setupScannerLayout() {
        view.backgroundColor = .black
        view.addSubview(qrScannerView)

        NSLayoutConstraint.activate([
            qrScannerView.topAnchor.constraint(equalTo: view.topAnchor),
            qrScannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            qrScannerView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            qrScannerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupFlashButton() {
        flashButton.addTarget(
            self,
            action: #selector(tapFlashButton(_:)),
            for: .touchUpInside
        )
        view.addSubview(flashButton)

        NSLayoutConstraint.activate([
            flashButton.centerXAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.centerXAnchor
            ),
            flashButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -24
            ),
        ])
    }

    private func setupQRScanner() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupQRScannerView()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async { [weak self] in
                        self?.setupQRScannerView()
                    }
                }
            }
        default:
            showAlert()
        }
    }

    private func setupQRScannerView() {
        qrScannerView.configure(
            delegate: self,
            input: .init(isBlurEffectEnabled: true)
        )
        qrScannerView.startRunning()
    }

    private func showAlert() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            let alert = UIAlertController(
                title: "Error",
                message: "Camera is required to use in this application",
                preferredStyle: .alert
            )
            alert.addAction(.init(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        qrScannerView.stopRunning()
    }

    // MARK: - Actions
    @objc private func tapFlashButton(_ sender: UIButton) {
        #if targetEnvironment(simulator)
            sender.isSelected.toggle()
        #else
            qrScannerView.setTorchActive(isOn: !sender.isSelected)
        #endif
    }
}

// MARK: - QRScannerViewDelegate
extension QRScannerViewController: QRScannerViewDelegate {
    func qrScannerView(
        _ qrScannerView: QRScannerView,
        didFailure error: QRScannerError
    ) {
        print(error.localizedDescription)
    }

    func qrScannerView(_ qrScannerView: QRScannerView, didSuccess code: String)
    {
        delegate?.didScanQRCode(code)
    }

    func qrScannerView(
        _ qrScannerView: QRScannerView,
        didChangeTorchActive isOn: Bool
    ) {
        flashButton.isSelected = isOn
    }
}

#Preview {
    QRScannerViewController()
}
