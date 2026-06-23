import UIKit
import Kingfisher
import UIComponentKit

public final class ReviewsViewController: UIViewController, ReviewsView {
    private let presenter: ReviewsPresenting
    private var viewModel: ReviewsViewModel?

    private let navBar = UIView()
    private let backButton = UIButton(type: .system)
    private let navTitle = UILabel()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let footerLabel = UILabel()
    private let footerSpinner = UIActivityIndicatorView(style: .medium)
    private let headerView = UIView()

    public init(presenter: ReviewsPresenting) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.background
        setupNav()
        setupTable()
        presenter.viewDidLoad()
    }

    public func show(viewModel: ReviewsViewModel) {
        self.viewModel = viewModel
        rebuildHeader(viewModel)
        tableView.reloadData()
    }

    public func show(errorMessage: String) {
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    public func appendReviews(_ items: [ReviewsViewModel.ReviewItem]) {
        guard var model = viewModel else { return }
        model = ReviewsViewModel(
            movieTitle: model.movieTitle,
            moviePosterURL: model.moviePosterURL,
            ratingText: model.ratingText,
            reviewCountText: model.reviewCountText,
            reviews: model.reviews + items,
            isLoadingMore: false
        )
        viewModel = model
        tableView.reloadData()
    }

    public func showLoadingFooter(_ visible: Bool) {
        footerSpinner.isHidden = !visible
        footerLabel.isHidden = !visible
        if visible { footerSpinner.startAnimating() } else { footerSpinner.stopAnimating() }
    }

    private func setupNav() {
        navBar.backgroundColor = AppColor.surfaceGlass
        navBar.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = AppColor.onSurface
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        navTitle.text = "User Reviews"
        navTitle.font = AppFont.headlineMD()
        navTitle.textColor = AppColor.highEmphasis
        navTitle.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        navBar.addSubview(backButton)
        navBar.addSubview(navTitle)
        view.addSubview(navBar)
        NSLayoutConstraint.activate([
            navBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navBar.heightAnchor.constraint(equalToConstant: 52),
            backButton.leadingAnchor.constraint(equalTo: navBar.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: navBar.centerYAnchor),
            navTitle.centerXAnchor.constraint(equalTo: navBar.centerXAnchor),
            navTitle.centerYAnchor.constraint(equalTo: navBar.centerYAnchor)
        ])
    }

    private func setupTable() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ReviewCell.self, forCellReuseIdentifier: ReviewCell.id)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        footerLabel.text = "Loading more reviews…"
        footerLabel.font = AppFont.labelSM()
        footerLabel.textColor = AppColor.onSurfaceVariant
        footerLabel.isHidden = true
        footerSpinner.isHidden = true
        let footer = UIStackView(arrangedSubviews: [footerSpinner, footerLabel])
        footer.axis = .horizontal
        footer.spacing = 8
        footer.alignment = .center
        tableView.tableFooterView = footer
        footer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 44)
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: navBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func rebuildHeader(_ model: ReviewsViewModel) {
        headerView.subviews.forEach { $0.removeFromSuperview() }
        let poster = UIImageView()
        poster.layer.cornerRadius = AppRadius.roundedMD
        poster.clipsToBounds = true
        poster.contentMode = .scaleAspectFill
        poster.kf.setImage(with: model.moviePosterURL)
        poster.translatesAutoresizingMaskIntoConstraints = false
        let title = UILabel()
        title.text = model.movieTitle
        title.font = AppFont.headlineMD()
        title.textColor = AppColor.highEmphasis
        title.numberOfLines = 2
        let rating = UILabel()
        rating.text = "★ \(model.ratingText) \(model.reviewCountText)"
        rating.font = AppFont.labelSM()
        rating.textColor = AppColor.onSurfaceVariant
        let textStack = UIStackView(arrangedSubviews: [title, rating])
        textStack.axis = .vertical
        textStack.spacing = 4
        let row = UIStackView(arrangedSubviews: [poster, textStack])
        row.spacing = 12
        row.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(row)
        NSLayoutConstraint.activate([
            poster.widthAnchor.constraint(equalToConstant: 56),
            poster.heightAnchor.constraint(equalToConstant: 84),
            row.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            row.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            row.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            row.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16)
        ])
        headerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 120)
        tableView.tableHeaderView = headerView
    }

    @objc private func backTapped() { navigationController?.popViewController(animated: true) }
}

extension ReviewsViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.reviews.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReviewCell.id, for: indexPath) as! ReviewCell
        if let item = viewModel?.reviews[indexPath.row] { cell.configure(item: item) }
        return cell
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y + scrollView.bounds.height
        if offset > scrollView.contentSize.height - 200 {
            presenter.viewDidScrollNearBottom()
        }
    }
}

private final class ReviewCell: UITableViewCell {
    static let id = "ReviewCell"
    private let card = UIView()
    private let avatar = UIImageView()
    private let nameLabel = UILabel()
    private let dateLabel = UILabel()
    private let ratingLabel = UILabel()
    private let bodyLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        card.backgroundColor = AppColor.surfaceContainer
        card.layer.cornerRadius = AppRadius.roundedLG
        card.translatesAutoresizingMaskIntoConstraints = false
        avatar.layer.cornerRadius = 20
        avatar.clipsToBounds = true
        avatar.backgroundColor = AppColor.surfaceContainerHigh
        avatar.contentMode = .scaleAspectFill
        nameLabel.font = AppFont.labelLG()
        nameLabel.textColor = AppColor.highEmphasis
        dateLabel.font = AppFont.labelSM()
        dateLabel.textColor = AppColor.onSurfaceVariant
        ratingLabel.font = AppFont.labelSM()
        ratingLabel.textColor = AppColor.ratingGold
        bodyLabel.font = AppFont.bodyMD()
        bodyLabel.textColor = AppColor.onSurface
        bodyLabel.numberOfLines = 0
        let top = UIStackView(arrangedSubviews: [avatar, nameLabel, UIView(), ratingLabel])
        top.alignment = .center
        let meta = UIStackView(arrangedSubviews: [top, dateLabel, bodyLabel])
        meta.axis = .vertical
        meta.spacing = 8
        meta.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(meta)
        contentView.addSubview(card)
        NSLayoutConstraint.activate([
            avatar.widthAnchor.constraint(equalToConstant: 40),
            avatar.heightAnchor.constraint(equalToConstant: 40),
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            meta.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            meta.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            meta.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            meta.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(item: ReviewsViewModel.ReviewItem) {
        nameLabel.text = item.author
        dateLabel.text = item.dateText
        ratingLabel.text = "★ \(item.ratingText)"
        bodyLabel.text = item.content
        if let url = item.avatarURL {
            avatar.kf.setImage(with: url)
        } else {
            avatar.image = nil
            avatar.backgroundColor = AppColor.surfaceContainerHigh
        }
    }
}
