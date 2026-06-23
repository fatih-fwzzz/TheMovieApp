import Foundation

public final class FavoritesPresenter: FavoritesPresenting {
    public weak var view: FavoritesView?

    private let interactor: FavoritesInteracting
    private let router: FavoritesRouting
    private var allItems: [MovieSnapshot] = []
    private var query = ""

    public init(interactor: FavoritesInteracting, router: FavoritesRouting) {
        self.interactor = interactor
        self.router = router
    }

    public func viewDidLoad() { reload() }

    public func searchQueryChanged(_ query: String) {
        self.query = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        view?.show(viewModel: makeViewModel())
    }

    public func didTapMovie(at index: Int) {
        let items = filteredItems()
        guard items.indices.contains(index),
              let viewController = (router as? FavoritesRouter)?.viewController else { return }
        router.showMovieDetail(movieId: items[index].id, from: viewController)
    }

    public func didToggleFavorite(at index: Int) {
        let items = filteredItems()
        guard items.indices.contains(index) else { return }
        interactor.removeFavorite(movieId: items[index].id)
        allItems = interactor.fetchFavorites()
        view?.removeItem(at: index)
        view?.show(viewModel: makeViewModel())
    }

    public func didTapBrowseMovies() {
        router.switchToHomeTab()
    }

    private func reload() {
        allItems = interactor.fetchFavorites()
        view?.show(viewModel: makeViewModel())
    }

    private func filteredItems() -> [MovieSnapshot] {
        guard !query.isEmpty else { return allItems }
        return allItems.filter { $0.title.lowercased().contains(query) }
    }

    private func makeViewModel() -> FavoritesViewModel {
        let items = filteredItems()
        return FavoritesViewModel(
            items: items.map {
                FavoritesViewModel.Item(
                    movieId: $0.id,
                    title: $0.title,
                    year: $0.releaseYear,
                    ratingText: String(format: "%.1f", $0.rating),
                    posterURL: TMDBImageURL.poster(path: $0.posterPath)
                )
            },
            countText: "\(allItems.count) Movies",
            isEmpty: allItems.isEmpty
        )
    }
}
