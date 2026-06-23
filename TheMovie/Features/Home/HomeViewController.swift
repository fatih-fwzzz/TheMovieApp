import UIKit
import Kingfisher
import SkeletonView

public final class HomeViewController: UIViewController, HomeView {
    private let presenter: HomePresenting
    private var viewModel: HomeViewModel?

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let logoLabel = UILabel()
    private let heroContainerView = UIView()
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
    private var heroAutoSlideTimer: Timer?
    private var isUserScrollingHero = false
    private var isProgrammaticHeroScroll = false
    private var pendingHeroIndex: Int?
    private var lastHeroItemIDs: [Int] = []

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

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startHeroAutoSlide()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopHeroAutoSlide()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let fullWidth = view.bounds.width
        let insetWidth = fullWidth - AppSpacing.containerMargin * 2
        heroLayout.itemSize = CGSize(width: fullWidth, height: 360)
        topTenLayout.itemSize = CGSize(width: insetWidth / 3.2, height: 180)
        let colWidth = (insetWidth - AppSpacing.gutter) / 2
        moviesLayout.itemSize = CGSize(width: colWidth, height: colWidth * 1.55)
        updateMoviesCollectionHeight()
    }

    public func show(viewModel: HomeViewModel) {
        let heroIDs = viewModel.heroItems.map(\.movieId)
        let heroDataChanged = heroIDs != lastHeroItemIDs
        lastHeroItemIDs = heroIDs

        self.viewModel = viewModel

        if heroDataChanged {
            heroCollectionView.reloadData()
            heroCollectionView.layoutIfNeeded()
            scrollHeroToIndex(viewModel.heroIndex, animated: false)
        } else if currentHeroPage() != viewModel.heroIndex,
                  !isUserScrollingHero,
                  !isProgrammaticHeroScroll {
            scrollHeroToIndex(viewModel.heroIndex, animated: false)
        }

        topTenCollectionView.reloadData()
        moviesCollectionView.reloadData()
        rebuildChips(viewModel.genreChips)
        pageControl.numberOfPages = viewModel.heroItems.count
        updateHeroOverlay(from: viewModel)
        loadingFooter.isHidden = !viewModel.isLoadingMore
        if viewModel.isLoadingMore { loadingFooter.startAnimating() } else { loadingFooter.stopAnimating() }
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

        // ── Header ──────────────────────────────────────────────────────────
        logoLabel.text = "TheMovie"
        logoLabel.font = AppFont.headlineXL()
        logoLabel.textColor = AppColor.primary

        let headerRow = UIStackView(arrangedSubviews: [logoLabel])
        headerRow.axis = .horizontal
        headerRow.alignment = .center
        headerRow.spacing = AppSpacing.stackMD

        let headerStack = UIStackView(arrangedSubviews: [headerRow])
        headerStack.axis = .vertical
        headerStack.alignment = .leading
        headerStack.layoutMargins = UIEdgeInsets(
            top: 0, left: AppSpacing.containerMargin,
            bottom: 0, right: AppSpacing.containerMargin
        )
        headerStack.isLayoutMarginsRelativeArrangement = true

        // ── Hero carousel ────────────────────────────────────────────────────
        heroCollectionView.backgroundColor = .clear
        heroCollectionView.isPagingEnabled = true
        heroCollectionView.showsHorizontalScrollIndicator = false
        heroCollectionView.delegate = self
        heroCollectionView.dataSource = self
        heroCollectionView.register(HeroCell.self, forCellWithReuseIdentifier: HeroCell.id)
        heroCollectionView.translatesAutoresizingMaskIntoConstraints = false

        // Title + button overlaid at bottom of image
        heroTitleLabel.font = AppFont.headlineXL()
        heroTitleLabel.textColor = AppColor.highEmphasis
        heroTitleLabel.numberOfLines = 2

        var trailerConfig = watchTrailerButton.configuration ?? UIButton.Configuration.plain()
        trailerConfig.title = "Watch Trailer"
        trailerConfig.image = UIImage(
            systemName: "play.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        )
        trailerConfig.imagePadding = 8
        trailerConfig.imagePlacement = .leading
        trailerConfig.baseForegroundColor = AppColor.highEmphasis
        watchTrailerButton.configuration = trailerConfig
        watchTrailerButton.tintColor = AppColor.highEmphasis
        watchTrailerButton.addTarget(self, action: #selector(trailerTapped), for: .touchUpInside)

        heroTitleLabel.textAlignment = .center

        let heroTextOverlay = UIStackView(arrangedSubviews: [heroTitleLabel, watchTrailerButton])
        heroTextOverlay.axis = .vertical
        heroTextOverlay.spacing = AppSpacing.stackMD
        heroTextOverlay.alignment = .center
        heroTextOverlay.layoutMargins = UIEdgeInsets(
            top: 0, left: AppSpacing.containerMargin,
            bottom: AppSpacing.stackLG, right: AppSpacing.containerMargin
        )
        heroTextOverlay.isLayoutMarginsRelativeArrangement = true
        heroTextOverlay.translatesAutoresizingMaskIntoConstraints = false

        heroContainerView.clipsToBounds = true
        heroContainerView.translatesAutoresizingMaskIntoConstraints = false
        heroContainerView.heightAnchor.constraint(equalToConstant: 360).isActive = true

        heroContainerView.addSubview(heroCollectionView)
        heroContainerView.addSubview(heroTextOverlay)

        NSLayoutConstraint.activate([
            heroCollectionView.topAnchor.constraint(equalTo: heroContainerView.topAnchor),
            heroCollectionView.leadingAnchor.constraint(equalTo: heroContainerView.leadingAnchor),
            heroCollectionView.trailingAnchor.constraint(equalTo: heroContainerView.trailingAnchor),
            heroCollectionView.bottomAnchor.constraint(equalTo: heroContainerView.bottomAnchor),
            heroTextOverlay.leadingAnchor.constraint(equalTo: heroContainerView.leadingAnchor),
            heroTextOverlay.trailingAnchor.constraint(equalTo: heroContainerView.trailingAnchor),
            heroTextOverlay.bottomAnchor.constraint(equalTo: heroContainerView.bottomAnchor)
        ])

        // ── "NOW TRENDING" + dots (below hero, centred) ─────────────────────
        trendingLabel.text = "NOW TRENDING"
        trendingLabel.font = AppFont.labelSM()
        trendingLabel.textColor = AppColor.onSurfaceVariant
        trendingLabel.textAlignment = .center

        pageControl.currentPageIndicatorTintColor = AppColor.primaryContainer
        pageControl.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.3)
        pageControl.addTarget(self, action: #selector(pageChanged), for: .valueChanged)

        let trendingInfoRow = UIStackView(arrangedSubviews: [trendingLabel, pageControl])
        trendingInfoRow.axis = .vertical
        trendingInfoRow.alignment = .center
        trendingInfoRow.spacing = AppSpacing.base

        // ── Top 10 ───────────────────────────────────────────────────────────
        topTenCollectionView.backgroundColor = .clear
        topTenCollectionView.showsHorizontalScrollIndicator = false
        topTenCollectionView.delegate = self
        topTenCollectionView.dataSource = self
        topTenCollectionView.register(PosterCell.self, forCellWithReuseIdentifier: PosterCell.id)
        topTenCollectionView.translatesAutoresizingMaskIntoConstraints = false
        topTenCollectionView.heightAnchor.constraint(equalToConstant: 180).isActive = true
        topTenCollectionView.contentInset = UIEdgeInsets(
            top: 0, left: AppSpacing.containerMargin,
            bottom: 0, right: AppSpacing.containerMargin
        )

        let topTenHeader = UILabel()
        topTenHeader.text = "Top 10 This Week"
        topTenHeader.font = AppFont.headlineMD()
        topTenHeader.textColor = AppColor.highEmphasis

        let topTenLabelRow = UIStackView(arrangedSubviews: [topTenHeader])
        topTenLabelRow.layoutMargins = UIEdgeInsets(
            top: 0, left: AppSpacing.containerMargin,
            bottom: 0, right: AppSpacing.containerMargin
        )
        topTenLabelRow.isLayoutMarginsRelativeArrangement = true

        let topTenSection = UIStackView(arrangedSubviews: [topTenLabelRow, topTenCollectionView])
        topTenSection.axis = .vertical
        topTenSection.spacing = AppSpacing.stackMD

        // ── All Movies ───────────────────────────────────────────────────────
        allMoviesHeader.text = "All Movies"
        allMoviesHeader.font = AppFont.headlineMD()
        allMoviesHeader.textColor = AppColor.highEmphasis

        chipsScrollView.showsHorizontalScrollIndicator = false
        chipsScrollView.contentInset = UIEdgeInsets(
            top: 0, left: AppSpacing.containerMargin,
            bottom: 0, right: AppSpacing.containerMargin
        )
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

        let moviesHeaderRow = UIStackView(arrangedSubviews: [allMoviesHeader])
        moviesHeaderRow.layoutMargins = UIEdgeInsets(
            top: 0, left: AppSpacing.containerMargin,
            bottom: 0, right: AppSpacing.containerMargin
        )
        moviesHeaderRow.isLayoutMarginsRelativeArrangement = true

        let moviesGrid = UIStackView(arrangedSubviews: [moviesCollectionView, loadingFooter])
        moviesGrid.axis = .vertical
        moviesGrid.spacing = AppSpacing.base
        moviesGrid.layoutMargins = UIEdgeInsets(
            top: 0, left: AppSpacing.containerMargin,
            bottom: 0, right: AppSpacing.containerMargin
        )
        moviesGrid.isLayoutMarginsRelativeArrangement = true

        let moviesSection = UIStackView(arrangedSubviews: [moviesHeaderRow, chipsScrollView, moviesGrid])
        moviesSection.axis = .vertical
        moviesSection.spacing = AppSpacing.stackMD

        // ── Compose content stack ────────────────────────────────────────────
        contentStack.addArrangedSubview(headerStack)
        contentStack.addArrangedSubview(heroContainerView)
        contentStack.setCustomSpacing(AppSpacing.base, after: heroContainerView)
        contentStack.addArrangedSubview(trendingInfoRow)
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
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -100),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
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

    @objc private func trailerTapped() { presenter.didTapWatchTrailer() }
    @objc private func pageChanged() {
        let page = pageControl.currentPage
        scrollHeroToIndex(page, animated: true)
    }
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

    private func startHeroAutoSlide() {
        stopHeroAutoSlide()
        heroAutoSlideTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.advanceHeroCarousel()
        }
    }

    private func stopHeroAutoSlide() {
        heroAutoSlideTimer?.invalidate()
        heroAutoSlideTimer = nil
    }

    private func advanceHeroCarousel() {
        guard !isUserScrollingHero,
              !isProgrammaticHeroScroll,
              let viewModel,
              !viewModel.heroItems.isEmpty else { return }
        let nextIndex = (viewModel.heroIndex + 1) % viewModel.heroItems.count
        scrollHeroToIndex(nextIndex, animated: true)
    }

    private func currentHeroPage() -> Int {
        let pageWidth = max(heroLayout.itemSize.width, heroCollectionView.bounds.width, 1)
        return Int(round(heroCollectionView.contentOffset.x / pageWidth))
    }

    private func scrollHeroToIndex(_ index: Int, animated: Bool) {
        guard viewModel?.heroItems.indices.contains(index) == true else { return }
        let pageWidth = max(heroLayout.itemSize.width, heroCollectionView.bounds.width, 1)
        let targetOffset = CGPoint(x: CGFloat(index) * pageWidth, y: 0)

        if animated {
            isProgrammaticHeroScroll = true
            pendingHeroIndex = index
            heroCollectionView.setContentOffset(targetOffset, animated: true)
        } else {
            heroCollectionView.setContentOffset(targetOffset, animated: false)
        }
    }

    private func finishProgrammaticHeroScrollIfNeeded() {
        guard isProgrammaticHeroScroll, let index = pendingHeroIndex, let viewModel else { return }
        isProgrammaticHeroScroll = false
        pendingHeroIndex = nil
        updateHeroOverlay(index: index, from: viewModel)
        if viewModel.heroIndex != index {
            presenter.didSelectHeroPage(index)
        }
    }

    private func updateHeroOverlay(from viewModel: HomeViewModel) {
        updateHeroOverlay(index: viewModel.heroIndex, from: viewModel)
    }

    private func updateHeroOverlay(index: Int, from viewModel: HomeViewModel) {
        pageControl.currentPage = index
        guard viewModel.heroItems.indices.contains(index) else { return }
        let hero = viewModel.heroItems[index]
        UIView.transition(with: heroTitleLabel, duration: 0.3, options: .transitionCrossDissolve) {
            self.heroTitleLabel.text = hero.title
        }
        watchTrailerButton.isHidden = !hero.hasTrailer
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
        } else if collectionView === topTenCollectionView {
            presenter.didTapTopTen(at: indexPath.item)
        }
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView === heroCollectionView {
            isUserScrollingHero = true
        }
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView === heroCollectionView, isProgrammaticHeroScroll || isUserScrollingHero {
            pageControl.currentPage = currentHeroPage()
            return
        }

        guard scrollView === self.scrollView else { return }
        let offset = scrollView.contentOffset.y + scrollView.bounds.height
        if offset > scrollView.contentSize.height - 200 {
            presenter.viewDidScrollNearBottom()
        }
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard scrollView === heroCollectionView else { return }
        finishProgrammaticHeroScrollIfNeeded()
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView === heroCollectionView {
            let page = currentHeroPage()
            if let viewModel {
                updateHeroOverlay(index: page, from: viewModel)
            }
            presenter.didSelectHeroPage(page)
            isUserScrollingHero = false
        }
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView === heroCollectionView, !decelerate {
            let page = currentHeroPage()
            if let viewModel {
                updateHeroOverlay(index: page, from: viewModel)
            }
            presenter.didSelectHeroPage(page)
            isUserScrollingHero = false
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
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        // Dissolve matching Movie Detail: near-transparent top → full background color at bottom
        gradient.colors = [
            UIColor.black.withAlphaComponent(0.15).cgColor,
            AppColor.background.cgColor
        ]
        gradient.locations = [0.0, 1.0]
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
