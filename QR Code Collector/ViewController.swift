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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        configureDataSource()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            collectionView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            collectionView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
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
}

#Preview {
    ViewController()
}
