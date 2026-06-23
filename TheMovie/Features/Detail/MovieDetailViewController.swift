import UIKit
import Kingfisher

public final class MovieDetailViewController: UIViewController, MovieDetailView {
    private let presenter: MovieDetailPresenting
    private var viewModel: MovieDetailViewModel?

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let backdropImageView = UIImageView()
    private let backdropGradient = CAGradientLayer()
    private let heroContainer = UIView()
    private let backButton = UIButton(type: .system)
    private let favoriteButton = UIButton(type: .system)
    private let posterImageView = UIImageView()
    private let titleLabel = UILabel()
    private let ratingLabel = UILabel()
    private let yearLabel = UILabel()
    private let runtimeLabel = UILabel()
    private let genreScrollView = UIScrollView()
    private let genreStack = UIStackView()
    private let overviewLabel = UILabel()
    private let readMoreButton = UIButton(type: .system)
    private let trailerButton = PrimaryButton()
    private let castTitleLabel = UILabel()
    private let castSeeAllButton = UIButton(type: .system)
    private let castCollectionView: UICollectionView
    private let reviewsTitleLabel = UILabel()
    private let reviewsStack = UIStackView()
    private let reviewsEmptyLabel = UILabel()
    private let showAllReviewsButton = UIButton(type: .system)
    private let loadingIndicator = UIActivityIndicatorView(style: .large)

    private let castLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = AppSpacing.gutter
        layout.itemSize = CGSize(width: 96, height: 140)
        return layout
    }()

    private enum Layout {
        static let backdropHeight: CGFloat = 320
        static let posterWidth: CGFloat = 110
        static let posterHeight: CGFloat = 165
        static let posterOverlap: CGFloat = 56
    }

    public init(presenter: MovieDetailPresenting) {
        self.presenter = presenter
        castCollectionView = UICollectionView(frame: .zero, collectionViewLayout: castLayout)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.background
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupUI()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter.viewDidAppear()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backdropGradient.frame = backdropImageView.bounds
    }

    public func show(viewModel: MovieDetailViewModel) {
        self.viewModel = viewModel
        loadingIndicator.isHidden = !viewModel.isLoading
        viewModel.isLoading ? loadingIndicator.startAnimating() : loadingIndicator.stopAnimating()

        backdropImageView.kf.setImage(with: viewModel.backdropURL, placeholder: UIImage(systemName: "film"))
        posterImageView.kf.setImage(with: viewModel.posterURL, placeholder: UIImage(systemName: "film"))
        titleLabel.text = viewModel.title
        ratingLabel.text = viewModel.ratingText
        yearLabel.text = viewModel.year
        runtimeLabel.text = viewModel.runtimeText
        overviewLabel.text = viewModel.overview
        overviewLabel.numberOfLines = viewModel.isOverviewExpanded ? 0 : 4
        readMoreButton.isHidden = viewModel.overview.count <= 160
        readMoreButton.setTitle(viewModel.isOverviewExpanded ? "Show less" : "Read more", for: .normal)
        trailerButton.isHidden = viewModel.trailerURL == nil
        favoriteButton.setImage(
            UIImage(systemName: viewModel.isFavorite ? "heart.fill" : "heart"),
            for: .normal
        )
        favoriteButton.tintColor = viewModel.isFavorite ? AppColor.primary : .white
        favoriteButton.isEnabled = !viewModel.isLoading

        backButton.tintColor = AppColor.primary

        rebuildGenres(viewModel.genres)
        castCollectionView.reloadData()
        castSeeAllButton.isHidden = viewModel.cast.isEmpty
        rebuildReviews(viewModel.previewReviews)
    }

    public func show(errorMessage: String) {
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func setupUI() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = AppSpacing.sectionGap
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        backdropImageView.contentMode = .scaleAspectFill
        backdropImageView.clipsToBounds = true
        backdropImageView.translatesAutoresizingMaskIntoConstraints = false
        backdropGradient.colors = [
            UIColor.black.withAlphaComponent(0.15).cgColor,
            AppColor.background.cgColor
        ]
        backdropGradient.locations = [0, 1]
        backdropImageView.layer.addSublayer(backdropGradient)

        heroContainer.translatesAutoresizingMaskIntoConstraints = false
        heroContainer.addSubview(backdropImageView)

        configureCircleButton(
            backButton,
            symbol: "chevron.left",
            action: #selector(backTapped),
            usesLiquidGlass: false,
            prominentBackground: true
        )
        configureCircleButton(favoriteButton, symbol: "heart", action: #selector(favoriteTapped), usesLiquidGlass: false)

        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = AppRadius.roundedMD
        posterImageView.layer.borderWidth = 1
        posterImageView.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        posterImageView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = AppColor.highEmphasis
        titleLabel.numberOfLines = 0

        ratingLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        ratingLabel.textColor = AppColor.highEmphasis

        yearLabel.font = .systemFont(ofSize: 14, weight: .medium)
        yearLabel.textColor = AppColor.onSurfaceVariant
        runtimeLabel.font = .systemFont(ofSize: 14, weight: .medium)
        runtimeLabel.textColor = AppColor.onSurfaceVariant

        let star = UIImageView(image: UIImage(systemName: "star.fill"))
        star.tintColor = AppColor.ratingGold
        star.translatesAutoresizingMaskIntoConstraints = false
        star.widthAnchor.constraint(equalToConstant: 14).isActive = true
        star.heightAnchor.constraint(equalToConstant: 14).isActive = true

        let ratingRow = UIStackView(arrangedSubviews: [star, ratingLabel, yearLabel])
        ratingRow.spacing = 6
        ratingRow.alignment = .center

        let clock = UIImageView(image: UIImage(systemName: "clock"))
        clock.tintColor = AppColor.onSurfaceVariant
        clock.translatesAutoresizingMaskIntoConstraints = false
        clock.widthAnchor.constraint(equalToConstant: 13).isActive = true
        clock.heightAnchor.constraint(equalToConstant: 13).isActive = true
        let runtimeRow = UIStackView(arrangedSubviews: [clock, runtimeLabel])
        runtimeRow.spacing = 4
        runtimeRow.alignment = .center

        let textStack = UIStackView(arrangedSubviews: [titleLabel, ratingRow, runtimeRow])
        textStack.axis = .vertical
        textStack.spacing = AppSpacing.stackSM
        textStack.translatesAutoresizingMaskIntoConstraints = false

        let identityRow = UIView()
        identityRow.translatesAutoresizingMaskIntoConstraints = false
        identityRow.addSubview(posterImageView)
        identityRow.addSubview(textStack)

        genreScrollView.showsHorizontalScrollIndicator = false
        genreScrollView.translatesAutoresizingMaskIntoConstraints = false
        genreStack.axis = .horizontal
        genreStack.spacing = AppSpacing.base
        genreStack.translatesAutoresizingMaskIntoConstraints = false
        genreScrollView.addSubview(genreStack)

        overviewLabel.font = AppFont.bodyLG()
        overviewLabel.textColor = AppColor.onSurfaceVariant
        overviewLabel.numberOfLines = 4
        readMoreButton.setTitleColor(AppColor.primary, for: .normal)
        readMoreButton.titleLabel?.font = AppFont.labelLG()
        readMoreButton.addTarget(self, action: #selector(readMoreTapped), for: .touchUpInside)

        configureTrailerButton()

        castTitleLabel.text = "Top Cast"
        castTitleLabel.font = AppFont.headlineMD()
        castTitleLabel.textColor = AppColor.highEmphasis

        castSeeAllButton.setTitle("See All", for: .normal)
        castSeeAllButton.setTitleColor(AppColor.primary, for: .normal)
        castSeeAllButton.titleLabel?.font = AppFont.labelLG()

        let castHeaderRow = UIStackView(arrangedSubviews: [castTitleLabel, UIView()])
        castHeaderRow.axis = .horizontal
        castHeaderRow.alignment = .center
        castHeaderRow.distribution = .fill

        castCollectionView.backgroundColor = .clear
        castCollectionView.showsHorizontalScrollIndicator = false
        castCollectionView.dataSource = self
        castCollectionView.delegate = self
        castCollectionView.register(CastCell.self, forCellWithReuseIdentifier: CastCell.id)
        castCollectionView.translatesAutoresizingMaskIntoConstraints = false
        castCollectionView.heightAnchor.constraint(equalToConstant: 140).isActive = true

        reviewsTitleLabel.text = "User Reviews"
        reviewsTitleLabel.font = AppFont.headlineMD()
        reviewsTitleLabel.textColor = AppColor.highEmphasis
        reviewsStack.axis = .vertical
        reviewsStack.spacing = AppSpacing.stackMD
        reviewsEmptyLabel.text = "No user reviews yet."
        reviewsEmptyLabel.font = AppFont.bodyLG()
        reviewsEmptyLabel.textColor = AppColor.onSurfaceVariant
        reviewsEmptyLabel.isHidden = true

        configureShowAllReviewsButton()

        let overviewStack = UIStackView(arrangedSubviews: [overviewLabel, readMoreButton])
        overviewStack.axis = .vertical
        overviewStack.spacing = AppSpacing.stackSM
        overviewStack.alignment = .leading

        let castStack = UIStackView(arrangedSubviews: [castHeaderRow, castCollectionView])
        castStack.axis = .vertical
        castStack.spacing = AppSpacing.stackMD

        let reviewsSection = UIStackView(arrangedSubviews: [
            reviewsTitleLabel, reviewsStack, reviewsEmptyLabel, showAllReviewsButton
        ])
        reviewsSection.axis = .vertical
        reviewsSection.spacing = AppSpacing.stackMD
        reviewsSection.alignment = .fill

        let paddedStack = UIStackView(arrangedSubviews: [
            identityRow,
            genreScrollView,
            overviewStack,
            trailerButton,
            castStack,
            reviewsSection
        ])
        paddedStack.axis = .vertical
        paddedStack.spacing = AppSpacing.stackLG
        paddedStack.translatesAutoresizingMaskIntoConstraints = false
        paddedStack.isLayoutMarginsRelativeArrangement = true
        paddedStack.layoutMargins = UIEdgeInsets(
            top: 0,
            left: AppSpacing.containerMargin,
            bottom: 0,
            right: AppSpacing.containerMargin
        )

        contentStack.addArrangedSubview(heroContainer)
        contentStack.addArrangedSubview(paddedStack)
        contentStack.setCustomSpacing(-Layout.posterOverlap, after: heroContainer)

        scrollView.addSubview(contentStack)
        view.addSubview(scrollView)
        view.addSubview(backButton)
        view.addSubview(favoriteButton)

        loadingIndicator.color = AppColor.onSurfaceVariant
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -32),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            backdropImageView.topAnchor.constraint(equalTo: heroContainer.topAnchor),
            backdropImageView.leadingAnchor.constraint(equalTo: heroContainer.leadingAnchor),
            backdropImageView.trailingAnchor.constraint(equalTo: heroContainer.trailingAnchor),
            backdropImageView.bottomAnchor.constraint(equalTo: heroContainer.bottomAnchor),
            heroContainer.heightAnchor.constraint(equalToConstant: Layout.backdropHeight),

            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AppSpacing.containerMargin),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            favoriteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AppSpacing.containerMargin),
            favoriteButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),

            posterImageView.leadingAnchor.constraint(equalTo: identityRow.leadingAnchor),
            posterImageView.topAnchor.constraint(equalTo: identityRow.topAnchor),
            posterImageView.bottomAnchor.constraint(lessThanOrEqualTo: identityRow.bottomAnchor),
            posterImageView.widthAnchor.constraint(equalToConstant: Layout.posterWidth),
            posterImageView.heightAnchor.constraint(equalToConstant: Layout.posterHeight),

            textStack.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: AppSpacing.gutter),
            textStack.trailingAnchor.constraint(equalTo: identityRow.trailingAnchor),
            textStack.bottomAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: -4),
            textStack.topAnchor.constraint(greaterThanOrEqualTo: identityRow.topAnchor),
            identityRow.heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.posterHeight - Layout.posterOverlap),

            genreStack.leadingAnchor.constraint(equalTo: genreScrollView.contentLayoutGuide.leadingAnchor),
            genreStack.trailingAnchor.constraint(equalTo: genreScrollView.contentLayoutGuide.trailingAnchor),
            genreStack.topAnchor.constraint(equalTo: genreScrollView.contentLayoutGuide.topAnchor),
            genreStack.bottomAnchor.constraint(equalTo: genreScrollView.contentLayoutGuide.bottomAnchor),
            genreStack.heightAnchor.constraint(equalTo: genreScrollView.frameLayoutGuide.heightAnchor),
            genreScrollView.heightAnchor.constraint(equalToConstant: 32),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        view.bringSubviewToFront(backButton)
        view.bringSubviewToFront(favoriteButton)
        view.bringSubviewToFront(loadingIndicator)
    }

    private func configureCircleButton(
        _ button: UIButton,
        symbol: String,
        action: Selector,
        usesLiquidGlass: Bool = true,
        prominentBackground: Bool = false
    ) {
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        button.setImage(UIImage(systemName: symbol, withConfiguration: iconConfig), for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.addTarget(self, action: action, for: .touchUpInside)
        if usesLiquidGlass {
            LiquidGlassStyle.apply(to: button, cornerRadius: 20, tintColor: AppColor.surfaceGlass)
        } else if prominentBackground {
            button.backgroundColor = UIColor.black.withAlphaComponent(0.65)
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
        } else {
            button.backgroundColor = AppColor.surfaceGlass
        }
    }

    private func rebuildGenres(_ genres: [String]) {
        genreStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for genre in genres {
            let chip = PaddingLabel(insets: UIEdgeInsets(top: 6, left: 14, bottom: 6, right: 14))
            chip.text = genre
            chip.font = .systemFont(ofSize: 12, weight: .medium)
            chip.textColor = AppColor.onSurface
            chip.backgroundColor = .clear
            chip.layer.cornerRadius = 14
            chip.layer.borderWidth = 1
            chip.layer.borderColor = AppColor.outline.withAlphaComponent(0.5).cgColor
            chip.clipsToBounds = true
            genreStack.addArrangedSubview(chip)
        }
    }

    private func configureTrailerButton() {
        var config = trailerButton.configuration ?? UIButton.Configuration.plain()
        config.title = "Watch Trailer"
        config.image = UIImage(
            systemName: "play.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        )
        config.imagePadding = 8
        config.imagePlacement = .leading
        config.baseForegroundColor = AppColor.highEmphasis
        trailerButton.configuration = config
        trailerButton.tintColor = AppColor.highEmphasis
        trailerButton.addTarget(self, action: #selector(trailerTapped), for: .touchUpInside)
    }

    private func configureShowAllReviewsButton() {
        showAllReviewsButton.setTitle("Show all", for: .normal)
        showAllReviewsButton.setTitleColor(AppColor.primary, for: .normal)
        UIButtonInsets.applyTitleFont(AppFont.labelLG(), to: showAllReviewsButton)
        showAllReviewsButton.layer.cornerRadius = AppRadius.roundedLG
        UIButtonInsets.apply(
            UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16),
            to: showAllReviewsButton
        )
        LiquidGlassStyle.apply(
            to: showAllReviewsButton,
            cornerRadius: AppRadius.roundedLG,
            tintColor: AppColor.surfaceContainer
        )
        showAllReviewsButton.addTarget(self, action: #selector(showAllReviewsTapped), for: .touchUpInside)
        showAllReviewsButton.isHidden = true
    }

    private func rebuildReviews(_ reviews: [MovieDetailViewModel.ReviewItem]) {
        reviewsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        reviewsEmptyLabel.isHidden = !reviews.isEmpty
        showAllReviewsButton.isHidden = reviews.isEmpty
        for review in reviews {
            reviewsStack.addArrangedSubview(makeReviewCard(review))
        }
    }

    private func makeReviewCard(_ review: MovieDetailViewModel.ReviewItem) -> UIView {
        let card = UIView()
        card.backgroundColor = AppColor.surfaceContainer
        card.layer.cornerRadius = AppRadius.roundedLG

        let avatar = UIImageView()
        avatar.layer.cornerRadius = 20
        avatar.clipsToBounds = true
        avatar.backgroundColor = AppColor.surfaceContainerHigh
        avatar.contentMode = .scaleAspectFill
        avatar.kf.setImage(with: review.avatarURL)
        avatar.translatesAutoresizingMaskIntoConstraints = false

        let authorLabel = UILabel()
        authorLabel.text = review.author
        authorLabel.font = AppFont.labelLG()
        authorLabel.textColor = AppColor.highEmphasis

        let dateLabel = UILabel()
        dateLabel.text = review.dateText
        dateLabel.font = AppFont.labelSM()
        dateLabel.textColor = AppColor.onSurfaceVariant

        let nameStack = UIStackView(arrangedSubviews: [authorLabel, dateLabel])
        nameStack.axis = .vertical
        nameStack.spacing = 2

        let header = UIStackView(arrangedSubviews: [avatar, nameStack])
        header.spacing = AppSpacing.stackMD
        header.alignment = .center

        let bodyLabel = UILabel()
        bodyLabel.text = review.content
        bodyLabel.font = AppFont.bodyMD()
        bodyLabel.textColor = AppColor.onSurface
        bodyLabel.numberOfLines = 4

        let stack = UIStackView(arrangedSubviews: [header, bodyLabel])
        stack.axis = .vertical
        stack.spacing = AppSpacing.stackSM
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)

        NSLayoutConstraint.activate([
            avatar.widthAnchor.constraint(equalToConstant: 40),
            avatar.heightAnchor.constraint(equalToConstant: 40),
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: AppSpacing.gutter),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: AppSpacing.gutter),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -AppSpacing.gutter),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -AppSpacing.gutter)
        ])
        return card
    }

    @objc private func backTapped() { presenter.didTapBack() }
    @objc private func favoriteTapped() { presenter.didTapFavorite() }
    @objc private func trailerTapped() { presenter.didTapWatchTrailer() }
    @objc private func readMoreTapped() { presenter.didToggleOverviewExpanded() }
    @objc private func showAllReviewsTapped() { presenter.didTapViewReviews() }
}

extension MovieDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.cast.count ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CastCell.id, for: indexPath) as! CastCell
        if let item = viewModel?.cast[indexPath.item] {
            cell.configure(with: item)
        }
        return cell
    }
}

private final class CastCell: UICollectionViewCell {
    static let id = "CastCell"
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let roleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 36
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = AppColor.outline.withAlphaComponent(0.4).cgColor
        imageView.backgroundColor = AppColor.surfaceContainerHigh
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        nameLabel.textColor = AppColor.highEmphasis
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 2
        nameLabel.lineBreakMode = .byWordWrapping
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.8
        roleLabel.font = .systemFont(ofSize: 11)
        roleLabel.textColor = AppColor.onSurfaceVariant
        roleLabel.textAlignment = .center
        roleLabel.numberOfLines = 2
        roleLabel.adjustsFontSizeToFitWidth = true
        roleLabel.minimumScaleFactor = 0.8
        let stack = UIStackView(arrangedSubviews: [imageView, nameLabel, roleLabel])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 72),
            imageView.heightAnchor.constraint(equalToConstant: 72),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with item: MovieDetailViewModel.CastItem) {
        nameLabel.text = item.name
        roleLabel.text = item.character
        imageView.kf.setImage(with: item.imageURL)
    }
}

private final class PaddingLabel: UILabel {
    private let insets: UIEdgeInsets

    init(insets: UIEdgeInsets) {
        self.insets = insets
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right, height: size.height + insets.top + insets.bottom)
    }
}
