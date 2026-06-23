import UIKit
import Kingfisher

public final class SearchViewController: UIViewController, SearchView {
    private let presenter: SearchPresenting
    private var viewModel: SearchViewModel?

    private let titleLabel = UILabel()
    private let searchBar = SearchBarView()
    private let sectionLabel = UILabel()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let spinner = UIActivityIndicatorView(style: .medium)

    public init(presenter: SearchPresenting) {
        self.presenter = presenter
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

    public func show(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        sectionLabel.text = viewModel.isSearching ? "Search Results" : "Top Trending"
        tableView.reloadData()
        viewModel.isLoading ? spinner.startAnimating() : spinner.stopAnimating()
    }

    public func show(errorMessage: String) {
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func setupUI() {
        titleLabel.text = "Search"
        titleLabel.font = AppFont.headlineXL()
        titleLabel.textColor = AppColor.highEmphasis
        searchBar.setPlaceholder("Find movies or genres")
        searchBar.textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        sectionLabel.font = AppFont.labelLG()
        sectionLabel.textColor = AppColor.highEmphasis
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TrendingCell.self, forCellReuseIdentifier: TrendingCell.id)
        tableView.register(SearchResultCell.self, forCellReuseIdentifier: SearchResultCell.id)
        spinner.color = AppColor.onSurfaceVariant

        let stack = UIStackView(arrangedSubviews: [titleLabel, searchBar, sectionLabel, tableView, spinner])
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

    @objc private func textChanged() {
        presenter.searchQueryChanged(searchBar.textField.text ?? "")
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.rows.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel else { return UITableViewCell() }
        switch viewModel.rows[indexPath.row] {
        case .trending(let row):
            let cell = tableView.dequeueReusableCell(withIdentifier: TrendingCell.id, for: indexPath) as! TrendingCell
            cell.configure(row: row)
            return cell
        case .searchResult(let row):
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultCell.id, for: indexPath) as! SearchResultCell
            cell.configure(row: row)
            return cell
        }
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectRow(at: indexPath.row)
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let viewModel else { return 88 }
        if case .searchResult = viewModel.rows[indexPath.row] { return 72 }
        return 80
    }
}

private final class TrendingCell: UITableViewCell {
    static let id = "TrendingCell"
    private let card = UIView()
    private let posterView = UIImageView()
    private let titleLabel = UILabel()
    private let yearLabel = UILabel()
    private let ratingView = StarRatingView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none

        card.backgroundColor = AppColor.surfaceContainer
        card.layer.cornerRadius = AppRadius.roundedLG
        card.clipsToBounds = true
        card.translatesAutoresizingMaskIntoConstraints = false

        posterView.contentMode = .scaleAspectFill
        posterView.clipsToBounds = true
        posterView.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = AppFont.labelLG()
        titleLabel.textColor = AppColor.highEmphasis
        titleLabel.numberOfLines = 1

        yearLabel.font = AppFont.labelSM()
        yearLabel.textColor = AppColor.onSurfaceVariant

        let textStack = UIStackView(arrangedSubviews: [titleLabel, yearLabel])
        textStack.axis = .vertical
        textStack.spacing = AppSpacing.stackSM
        textStack.translatesAutoresizingMaskIntoConstraints = false

        let infoRow = UIStackView(arrangedSubviews: [textStack, UIView(), ratingView])
        infoRow.axis = .horizontal
        infoRow.alignment = .center
        infoRow.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(posterView)
        card.addSubview(infoRow)
        contentView.addSubview(card)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            posterView.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            posterView.topAnchor.constraint(equalTo: card.topAnchor),
            posterView.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            posterView.widthAnchor.constraint(equalToConstant: 72),

            infoRow.leadingAnchor.constraint(equalTo: posterView.trailingAnchor, constant: 12),
            infoRow.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            infoRow.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(row: SearchViewModel.TrendingRow) {
        titleLabel.text = row.title
        yearLabel.text = row.year
        ratingView.configure(score: row.ratingText, goldScore: true)
        posterView.kf.setImage(with: row.posterURL, placeholder: UIImage(systemName: "film"))
    }
}

private final class SearchResultCell: UITableViewCell {
    static let id = "SearchResultCell"
    private let poster = UIImageView()
    private let titleLabel = UILabel()
    private let yearLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        poster.layer.cornerRadius = AppRadius.roundedMD
        poster.clipsToBounds = true
        poster.contentMode = .scaleAspectFill
        poster.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = AppFont.labelLG()
        titleLabel.textColor = AppColor.highEmphasis
        yearLabel.font = AppFont.labelSM()
        yearLabel.textColor = AppColor.onSurfaceVariant
        let text = UIStackView(arrangedSubviews: [titleLabel, yearLabel])
        text.axis = .vertical
        let row = UIStackView(arrangedSubviews: [poster, text])
        row.spacing = 12
        row.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(row)
        NSLayoutConstraint.activate([
            poster.widthAnchor.constraint(equalToConstant: 48),
            poster.heightAnchor.constraint(equalToConstant: 72),
            row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            row.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(row: SearchViewModel.SearchRow) {
        titleLabel.text = row.title
        yearLabel.text = row.year
        poster.kf.setImage(with: row.posterURL)
    }
}
