import UIKit

class ViewController: UIViewController {
    nonisolated enum Section: Hashable {
        case main
    }

    private var dataSource:
        UICollectionViewDiffableDataSource<Section, QRCodeItem>!
    private var style: Style = .grid
    private var qrCodeItems: [QRCodeItem] = []

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: makeGridLayout()
        )
        // Required for programmatic Auto Layout
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        // Must register cell before dequeuing
        for cellType in [QRCodeGridCell.self, QRCodeListCell.self] {
            collectionView.register(
                cellType,
                forCellWithReuseIdentifier: cellType.reuseIdentifier
            )
        }
        collectionView.delegate = self
        return collectionView
    }()

    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Grid", "List"])
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    private func makeGridLayout() -> UICollectionViewLayout {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .fractionalHeight(1)
            )
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(180)
            ),
            repeatingSubitem: item,
            count: 2
        )
        group.interItemSpacing = .fixed(12)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = .init(
            top: 12,
            leading: 16,
            bottom: 12,
            trailing: 16
        )

        return UICollectionViewCompositionalLayout(section: section)
    }
    private func makeListLayout() -> UICollectionViewLayout {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(80)
            )
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(80)
            ),
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = .init(
            top: 12,
            leading: 16,
            bottom: 12,
            trailing: 16
        )

        return UICollectionViewCompositionalLayout(section: section)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        configureDataSource()
        loadSampleData()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        title = "QR Codes"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Scan",
            style: .plain,
            target: self,
            action: #selector(scanTapped)
        )
        segmentedControl.addTarget(
            self,
            action: #selector(layoutChanged),
            for: .valueChanged
        )
        view.addSubview(segmentedControl)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(
                equalTo: segmentedControl.bottomAnchor
            ),
            collectionView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            collectionView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            segmentedControl.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 8
            ),
            segmentedControl.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            segmentedControl.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
        ])
    }

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, QRCodeItem>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, item in
            let cellType = (self?.style ?? .grid).cellType
            let cell =
                collectionView.dequeueReusableCell(
                    withReuseIdentifier: cellType.reuseIdentifier,
                    for: indexPath
                ) as! QRCodeCell

            cell.configure(with: item)
            return cell
        }
    }

    // Call this method whenever your items change
    func applySnapshot(items: [QRCodeItem], animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, QRCodeItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }

    @objc private func scanTapped() {
        let scannerVC = QRScannerViewController()
        scannerVC.delegate = self
        if let navigationController = self.navigationController {
            navigationController.pushViewController(scannerVC, animated: true)
        }
    }

    @objc private func layoutChanged() {
        style = segmentedControl.selectedSegmentIndex == 0 ? .grid : .list
        let layout = style == .grid ? makeGridLayout() : makeListLayout()

        var snapshot = dataSource.snapshot()
        // Cell class differs per style, so items must be reloaded, not just reconfigured
        snapshot.reloadItems(snapshot.itemIdentifiers)
        dataSource.apply(snapshot, animatingDifferences: false)

        collectionView.setCollectionViewLayout(layout, animated: true)
    }

    private func loadSampleData() {
        let items = [
            QRCodeItem(value: "https://www.apple.com", scannedAt: Date()),
            QRCodeItem(
                value: "WIFI:T:WPA;S:MyNetwork;P:password123;;",
                scannedAt: Date()
            ),
            QRCodeItem(value: "mailto:hello@example.com", scannedAt: Date()),
            QRCodeItem(value: "tel:+1234567890", scannedAt: Date()),
        ]
        qrCodeItems += items
        applySnapshot(items: qrCodeItems, animatingDifferences: false)
    }
}

// MARK: - UICollectionViewDelegate
extension ViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        let form = QRCodeFormViewController(with: item)
        let nav = UINavigationController(rootViewController: form)
        if let sheet = nav.sheetPresentationController {
            // Sizes the sheet to fit its content instead of a fixed half-height.
            let width = view.bounds.width
            let fitContent = UISheetPresentationController.Detent.custom {
                [weak nav, weak form] context in
                guard let nav, let form else { return nil }
                let height =
                    form.fittingHeight(forWidth: width)
                    + nav.navigationBar.sizeThatFits(.zero).height
                return min(height, context.maximumDetentValue)
            }
            sheet.detents = [fitContent, .large()]
            sheet.prefersGrabberVisible = true
        }
        present(nav, animated: true)
    }
}

// MARK: - QRScannerViewControllerDelegate
extension ViewController: QRScannerViewControllerDelegate {
    func didScanQRCode(_ value: String) {
        qrCodeItems.append(QRCodeItem(value: value, scannedAt: Date.now))
        applySnapshot(items: qrCodeItems, animatingDifferences: true)
    }
}

#Preview {
    UINavigationController(rootViewController: ViewController())
}
