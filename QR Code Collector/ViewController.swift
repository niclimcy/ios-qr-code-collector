import UIKit

class ViewController: UIViewController {
    nonisolated enum Section: Hashable {
        case main
    }
    
    private var dataSource:
    UICollectionViewDiffableDataSource<Section, QRCodeItem>!
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        // Required for programmatic Auto Layout
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        // Must register cell before dequeuing
        collectionView.register(
            QRCodeCell.self,
            forCellWithReuseIdentifier: QRCodeCell.reuseIdentifier
        )
        return collectionView
    }()
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Grid", "List"])
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
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
        ) { collectionView, indexPath, item in
            let cell =
            collectionView.dequeueReusableCell(
                withReuseIdentifier: QRCodeCell.reuseIdentifier,
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
        // TODO: open scanner
    }
    
    private func loadSampleData() {
    let items = [
        QRCodeItem(value: "https://www.apple.com", scannedAt: Date()),
        QRCodeItem(value: "WIFI:T:WPA;S:MyNetwork;P:password123;;", scannedAt: Date()),
        QRCodeItem(value: "mailto:hello@example.com", scannedAt: Date()),
        QRCodeItem(value: "tel:+1234567890", scannedAt: Date()),
    ]
    applySnapshot(items: items, animatingDifferences: false)
}
}

#Preview {
    ViewController()
}
