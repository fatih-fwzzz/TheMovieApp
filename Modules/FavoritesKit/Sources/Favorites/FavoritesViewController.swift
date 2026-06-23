import UIKit
import Kingfisher
import UIComponentKit

public final class FavoritesViewController: UIViewController, FavoritesView {
    private let presenter: FavoritesPresenting
    private var viewModel: FavoritesViewModel?

    private let headerStack = UIStackView()
    private let titleLabel = UILabel()
    private let countLabel = UILabel()
    private let searchBar = SearchBarView()
    private let collectionView: UICollectionView
    private let emptyState = EmptyStateView()

    private let layout: UICollectionViewFlowLayout = {
        let l = UICollectionViewFlowLayout()
        l.minimumInteritemSpacing = AppSpacing.gutter
        l.minimumLineSpacing = AppSpacing.gutter
        return l
    }()

    public init(presenter: FavoritesPresenting) {
        self.presenter = presenter
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.background
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupUI()
        presenter.viewDidLoad()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let width = view.bounds.width - AppSpacing.containerMargin * 2
        layout.itemSize = CGSize(width: (width - AppSpacing.gutter) / 2, height: 280)
    }

    public func show(viewModel: FavoritesViewModel) {
        self.viewModel = viewModel
        countLabel.text = viewModel.countText
        collectionView.isHidden = viewModel.isEmpty
        emptyState.isHidden = !viewModel.isEmpty
        collectionView.reloadData()
    }

    public func show(errorMessage: String) {
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    public func removeItem(at index: Int) {
        guard let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) else { return }
        UIView.animate(withDuration: 0.25, animations: {
            cell.alpha = 0
            cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        })
    }

    private func setupUI() {
        titleLabel.text = "Favorites"
        titleLabel.font = AppFont.headlineXL()
        titleLabel.textColor = AppColor.highEmphasis
        countLabel.font = AppFont.labelLG()
        countLabel.textColor = AppColor.onSurfaceVariant
        searchBar.setPlaceholder("Find your favorite movies")
        searchBar.textField.addTarget(self, action: #selector(searchChanged), for: .editingChanged)

        headerStack.axis = .horizontal
        headerStack.distribution = .equalSpacing
        headerStack.addArrangedSubview(titleLabel)
        headerStack.addArrangedSubview(countLabel)

        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(FavoriteCell.self, forCellWithReuseIdentifier: FavoriteCell.id)

        emptyState.configure(message: "No favorites yet. Start exploring!", actionTitle: "Browse Movies")
        emptyState.actionButton.addTarget(self, action: #selector(browseTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [headerStack, searchBar, collectionView, emptyState])
        stack.axis = .vertical
        stack.spacing = AppSpacing.stackMD
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: AppSpacing.containerMargin),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AppSpacing.containerMargin),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AppSpacing.containerMargin),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func searchChanged() {
        presenter.searchQueryChanged(searchBar.textField.text ?? "")
    }

    @objc private func browseTapped() { presenter.didTapBrowseMovies() }
}

extension FavoritesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.items.count ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavoriteCell.id, for: indexPath) as! FavoriteCell
        if let item = viewModel?.items[indexPath.item] {
            cell.configure(item: item)
            cell.heartTapped = { [weak self] in self?.presenter.didToggleFavorite(at: indexPath.item) }
        }
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.didTapMovie(at: indexPath.item)
    }
}

private final class FavoriteCell: UICollectionViewCell {
    static let id = "FavoriteCell"
    private let posterView = UIImageView()
    private let heartButton = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let metaLabel = UILabel()
  var heartTapped: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = AppColor.surface
        contentView.layer.cornerRadius = AppRadius.roundedLG
        posterView.contentMode = .scaleAspectFill
        posterView.clipsToBounds = true
        posterView.layer.cornerRadius = AppRadius.roundedLG
        posterView.translatesAutoresizingMaskIntoConstraints = false
        heartButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        heartButton.tintColor = .white
        heartButton.backgroundColor = AppColor.primaryContainer
        heartButton.layer.cornerRadius = 16
        heartButton.translatesAutoresizingMaskIntoConstraints = false
        heartButton.addTarget(self, action: #selector(heartTap), for: .touchUpInside)
        titleLabel.font = AppFont.bodyMD()
        titleLabel.textColor = AppColor.highEmphasis
        titleLabel.numberOfLines = 2
        metaLabel.font = AppFont.labelSM()
        metaLabel.textColor = AppColor.onSurfaceVariant
        let textStack = UIStackView(arrangedSubviews: [titleLabel, metaLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(posterView)
        contentView.addSubview(heartButton)
        contentView.addSubview(textStack)
        NSLayoutConstraint.activate([
            posterView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1.25),
            heartButton.topAnchor.constraint(equalTo: posterView.topAnchor, constant: 8),
            heartButton.trailingAnchor.constraint(equalTo: posterView.trailingAnchor, constant: -8),
            heartButton.widthAnchor.constraint(equalToConstant: 32),
            heartButton.heightAnchor.constraint(equalToConstant: 32),
            textStack.topAnchor.constraint(equalTo: posterView.bottomAnchor, constant: 8),
            textStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            textStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            textStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(item: FavoritesViewModel.Item) {
        titleLabel.text = item.title
        metaLabel.text = "\(item.year)  ★ \(item.ratingText)"
        posterView.kf.setImage(with: item.posterURL)
    }

    @objc private func heartTap() { heartTapped?() }
}
