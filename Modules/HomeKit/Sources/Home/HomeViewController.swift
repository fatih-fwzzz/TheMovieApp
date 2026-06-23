import UIKit
import Kingfisher
import UIComponentKit
import SkeletonView

public final class HomeViewController: UIViewController, HomeView {
    private let presenter: HomePresenting
    private var viewModel: HomeViewModel?

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let logoLabel = UILabel()
    private let allPill = AllFilterPillButton()
    private let heroCollectionView: UICollectionView
    private let heroTitleLabel = UILabel()
    private let watchTrailerButton = PrimaryButton()
    private let trendingLabel = UILabel()
    private let pageControl = UIPageControl()
    private let topTenCollectionView: UICollectionView
    private let allMoviesHeader = UILabel()
    private let chipsScrollView = UIScrollView()
    private let chipsStack = UIStackView()
    private let moviesCollectionView: UICollectionView
    private let loadingFooter = UIActivityIndicatorView(style: .medium)
    private var moviesCollectionHeightConstraint: NSLayoutConstraint?

    private let heroLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        return layout
    }()

    private let topTenLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = AppSpacing.gutter
        return layout
    }()

    private let moviesLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = AppSpacing.gutter
        layout.minimumLineSpacing = AppSpacing.gutter
        return layout
    }()

    public init(presenter: HomePresenting) {
        self.presenter = presenter
        heroCollectionView = UICollectionView(frame: .zero, collectionViewLayout: heroLayout)
        topTenCollectionView = UICollectionView(frame: .zero, collectionViewLayout: topTenLayout)
        moviesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: moviesLayout)
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
        heroLayout.itemSize = CGSize(width: view.bounds.width, height: 280)
        topTenLayout.itemSize = CGSize(width: width / 3.2, height: 180)
        let colWidth = (width - AppSpacing.gutter) / 2
        moviesLayout.itemSize = CGSize(width: colWidth, height: colWidth * 1.55)
        updateMoviesCollectionHeight()
    }

    public func show(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        heroCollectionView.reloadData()
        topTenCollectionView.reloadData()
        moviesCollectionView.reloadData()
        rebuildChips(viewModel.genreChips)
        pageControl.numberOfPages = viewModel.heroItems.count
        pageControl.currentPage = viewModel.heroIndex
        if viewModel.heroItems.indices.contains(viewModel.heroIndex) {
            let hero = viewModel.heroItems[viewModel.heroIndex]
            heroTitleLabel.text = hero.title
            watchTrailerButton.isHidden = !hero.hasTrailer
        }
        loadingFooter.isHidden = !viewModel.isLoadingMore
        if viewModel.isLoadingMore { loadingFooter.startAnimating() } else { loadingFooter.stopAnimating() }
        allPill.alpha = viewModel.isAllFilterActive ? 1 : 0.6
        updateMoviesCollectionHeight()
    }

    public func show(errorMessage: String) {
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    public func appendMovies(_ items: [HomeViewModel.MovieItem]) {
        guard var model = viewModel else { return }
        model = HomeViewModel(
            heroItems: model.heroItems,
            heroIndex: model.heroIndex,
            topTen: model.topTen,
            movies: model.movies + items,
            genreChips: model.genreChips,
            isAllFilterActive: model.isAllFilterActive,
            isLoadingMore: false
        )
        viewModel = model
        moviesCollectionView.reloadData()
        updateMoviesCollectionHeight()
    }

    public func showGridLoadingFooter(_ visible: Bool) {
        loadingFooter.isHidden = !visible
        if visible { loadingFooter.startAnimating() } else { loadingFooter.stopAnimating() }
    }

    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = AppSpacing.stackLG
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        logoLabel.text = "TheMovie"
        logoLabel.font = AppFont.labelLG()
        logoLabel.textColor = AppColor.primary

        allPill.addTarget(self, action: #selector(allTapped), for: .touchUpInside)

        heroCollectionView.backgroundColor = .clear
        heroCollectionView.isPagingEnabled = true
        heroCollectionView.showsHorizontalScrollIndicator = false
        heroCollectionView.delegate = self
        heroCollectionView.dataSource = self
        heroCollectionView.register(HeroCell.self, forCellWithReuseIdentifier: HeroCell.id)
        heroCollectionView.translatesAutoresizingMaskIntoConstraints = false
        heroCollectionView.heightAnchor.constraint(equalToConstant: 280).isActive = true

        heroTitleLabel.font = AppFont.headlineXL()
        heroTitleLabel.textColor = AppColor.highEmphasis
        heroTitleLabel.numberOfLines = 2

        watchTrailerButton.setTitle("Watch Trailer", for: .normal)
        watchTrailerButton.addTarget(self, action: #selector(trailerTapped), for: .touchUpInside)

        trendingLabel.text = "NOW TRENDING"
        trendingLabel.font = AppFont.labelSM()
        trendingLabel.textColor = AppColor.onSurfaceVariant

        pageControl.currentPageIndicatorTintColor = AppColor.primaryContainer
        pageControl.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.3)
        pageControl.addTarget(self, action: #selector(pageChanged), for: .valueChanged)

        topTenCollectionView.backgroundColor = .clear
        topTenCollectionView.showsHorizontalScrollIndicator = false
        topTenCollectionView.delegate = self
        topTenCollectionView.dataSource = self
        topTenCollectionView.register(PosterCell.self, forCellWithReuseIdentifier: PosterCell.id)
        topTenCollectionView.translatesAutoresizingMaskIntoConstraints = false
        topTenCollectionView.heightAnchor.constraint(equalToConstant: 180).isActive = true

        allMoviesHeader.text = "All Movies"
        allMoviesHeader.font = AppFont.headlineMD()
        allMoviesHeader.textColor = AppColor.highEmphasis

        chipsScrollView.showsHorizontalScrollIndicator = false
        chipsStack.axis = .horizontal
        chipsStack.spacing = AppSpacing.base
        chipsStack.translatesAutoresizingMaskIntoConstraints = false
        chipsScrollView.translatesAutoresizingMaskIntoConstraints = false
        chipsScrollView.addSubview(chipsStack)
        NSLayoutConstraint.activate([
            chipsStack.leadingAnchor.constraint(equalTo: chipsScrollView.contentLayoutGuide.leadingAnchor),
            chipsStack.trailingAnchor.constraint(equalTo: chipsScrollView.contentLayoutGuide.trailingAnchor),
            chipsStack.topAnchor.constraint(equalTo: chipsScrollView.contentLayoutGuide.topAnchor),
            chipsStack.bottomAnchor.constraint(equalTo: chipsScrollView.contentLayoutGuide.bottomAnchor),
            chipsStack.heightAnchor.constraint(equalTo: chipsScrollView.frameLayoutGuide.heightAnchor),
            chipsScrollView.heightAnchor.constraint(equalToConstant: 40)
        ])

        moviesCollectionView.backgroundColor = .clear
        moviesCollectionView.delegate = self
        moviesCollectionView.dataSource = self
        moviesCollectionView.register(MovieGridCell.self, forCellWithReuseIdentifier: MovieGridCell.id)
        moviesCollectionView.isScrollEnabled = false
        moviesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        moviesCollectionHeightConstraint = moviesCollectionView.heightAnchor.constraint(equalToConstant: 0)
        moviesCollectionHeightConstraint?.isActive = true

        loadingFooter.color = AppColor.onSurfaceVariant

        let headerStack = UIStackView(arrangedSubviews: [logoLabel, allPill])
        headerStack.axis = .vertical
        headerStack.alignment = .leading
        headerStack.spacing = AppSpacing.stackMD

        let heroOverlay = UIStackView(arrangedSubviews: [heroTitleLabel, watchTrailerButton, trendingLabel, pageControl])
        heroOverlay.axis = .vertical
        heroOverlay.spacing = AppSpacing.stackMD
        heroOverlay.layoutMargins = UIEdgeInsets(top: 0, left: AppSpacing.containerMargin, bottom: 16, right: AppSpacing.containerMargin)
        heroOverlay.isLayoutMarginsRelativeArrangement = true

        let topTenHeader = UILabel()
        topTenHeader.text = "Top 10 This Week"
        topTenHeader.font = AppFont.headlineMD()
        topTenHeader.textColor = AppColor.highEmphasis

        let topTenSection = UIStackView(arrangedSubviews: [topTenHeader, topTenCollectionView])
        topTenSection.axis = .vertical
        topTenSection.spacing = AppSpacing.stackMD

        let moviesSection = UIStackView(arrangedSubviews: [allMoviesHeader, chipsScrollView, moviesCollectionView, loadingFooter])
        moviesSection.axis = .vertical
        moviesSection.spacing = AppSpacing.stackMD

        contentStack.addArrangedSubview(headerStack)
        contentStack.addArrangedSubview(heroCollectionView)
        contentStack.addArrangedSubview(heroOverlay)
        contentStack.addArrangedSubview(topTenSection)
        contentStack.addArrangedSubview(moviesSection)

        scrollView.delegate = self
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: AppSpacing.containerMargin),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -AppSpacing.containerMargin),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -100),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -AppSpacing.containerMargin * 2)
        ])

        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        scrollView.refreshControl = refresh
    }

    private func rebuildChips(_ chips: [HomeViewModel.GenreChipItem]) {
        chipsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, chip) in chips.enumerated() {
            let button = GenreChipButton()
            button.setTitle(chip.name, for: .normal)
            button.isChipSelected = chip.isSelected
            button.tag = index
            button.addTarget(self, action: #selector(chipTapped(_:)), for: .touchUpInside)
            chipsStack.addArrangedSubview(button)
        }
    }

    @objc private func allTapped() { presenter.didTapAllFilter() }
    @objc private func trailerTapped() { presenter.didTapWatchTrailer() }
    @objc private func pageChanged() { presenter.didSelectHeroPage(pageControl.currentPage) }
    @objc private func chipTapped(_ sender: UIButton) { presenter.didSelectGenreChip(at: sender.tag) }
    @objc private func refreshPulled() {
        presenter.refreshMovies()
        scrollView.refreshControl?.endRefreshing()
    }

    private func updateMoviesCollectionHeight() {
        let count = viewModel?.movies.count ?? 0
        guard count > 0 else {
            moviesCollectionHeightConstraint?.constant = 0
            return
        }
        let columns = 2.0
        let rows = ceil(Double(count) / columns)
        let itemHeight = moviesLayout.itemSize.height
        let spacing = moviesLayout.minimumLineSpacing
        let height = rows * itemHeight + max(0, rows - 1) * spacing
        moviesCollectionHeightConstraint?.constant = height
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewModel else { return 0 }
        if collectionView === heroCollectionView { return viewModel.heroItems.count }
        if collectionView === topTenCollectionView { return viewModel.topTen.count }
        return viewModel.movies.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewModel else { return UICollectionViewCell() }
        if collectionView === heroCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeroCell.id, for: indexPath) as! HeroCell
            cell.configure(with: viewModel.heroItems[indexPath.item])
            return cell
        }
        if collectionView === topTenCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PosterCell.id, for: indexPath) as! PosterCell
            cell.configure(url: viewModel.topTen[indexPath.item].posterURL)
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieGridCell.id, for: indexPath) as! MovieGridCell
        cell.configure(with: viewModel.movies[indexPath.item])
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView === moviesCollectionView {
            presenter.didTapMovie(at: indexPath.item)
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView === heroCollectionView {
            let page = Int(scrollView.contentOffset.x / max(scrollView.bounds.width, 1))
            presenter.didSelectHeroPage(page)
        }
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === self.scrollView else { return }
        let offset = scrollView.contentOffset.y + scrollView.bounds.height
        if offset > scrollView.contentSize.height - 200 {
            presenter.viewDidScrollNearBottom()
        }
    }
}

// MARK: - Cells

private final class HeroCell: UICollectionViewCell {
    static let id = "HeroCell"
    private let imageView = UIImageView()
    private let gradient = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: -AppSpacing.containerMargin),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: AppSpacing.containerMargin),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.8).cgColor]
        imageView.layer.addSublayer(gradient)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = imageView.bounds
    }

    func configure(with item: HomeViewModel.HeroItem) {
        imageView.kf.setImage(with: item.backdropURL, placeholder: UIImage(systemName: "film"))
    }
}

private final class PosterCell: UICollectionViewCell {
    static let id = "PosterCell"
    private let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = AppRadius.roundedLG
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(url: URL?) {
        imageView.kf.setImage(with: url, placeholder: UIImage(systemName: "film"))
    }
}

private final class MovieGridCell: UICollectionViewCell {
    static let id = "MovieGridCell"
    private let posterView = UIImageView()
    private let titleLabel = UILabel()
    private let metaLabel = UILabel()
    private let ratingView = StarRatingView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = AppColor.surface
        contentView.layer.cornerRadius = AppRadius.roundedLG
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor

        posterView.contentMode = .scaleAspectFill
        posterView.clipsToBounds = true
        posterView.layer.cornerRadius = AppRadius.roundedLG
        posterView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        posterView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = AppFont.bodyMD()
        titleLabel.textColor = AppColor.highEmphasis
        titleLabel.numberOfLines = 2

        metaLabel.font = AppFont.labelSM()
        metaLabel.textColor = AppColor.onSurfaceVariant

        let textStack = UIStackView(arrangedSubviews: [titleLabel, metaLabel, ratingView])
        textStack.axis = .vertical
        textStack.spacing = AppSpacing.stackSM
        textStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(posterView)
        contentView.addSubview(textStack)
        NSLayoutConstraint.activate([
            posterView.topAnchor.constraint(equalTo: contentView.topAnchor),
            posterView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1.2),
            textStack.topAnchor.constraint(equalTo: posterView.bottomAnchor, constant: AppSpacing.stackSM),
            textStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            textStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            textStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with item: HomeViewModel.MovieItem) {
        titleLabel.text = item.title
        metaLabel.text = item.year
        ratingView.configure(score: item.ratingText)
        posterView.kf.setImage(with: item.posterURL, placeholder: UIImage(systemName: "film"))
    }
}
