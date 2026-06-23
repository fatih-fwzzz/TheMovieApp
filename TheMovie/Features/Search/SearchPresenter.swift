import Foundation

public final class SearchPresenter: SearchPresenting {
    public weak var view: SearchView?

    private let interactor: SearchInteracting
    private let router: SearchRouting

    private var trending: [Movie] = []
    private var searchResults: [Movie] = []
    private var query = ""
    private var searchTask: Task<Void, Never>?

    public init(interactor: SearchInteracting, router: SearchRouting) {
        self.interactor = interactor
        self.router = router
    }

    public func viewDidLoad() {
        Task {
            do {
                trending = try await interactor.fetchTrending()
                await presentViewModel(isLoading: false)
            } catch {
                await presentError((error as? LocalizedError)?.errorDescription ?? "Failed to load trending.")
            }
        }
    }

    public func searchQueryChanged(_ query: String) {
        self.query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        searchTask?.cancel()
        guard !self.query.isEmpty else {
            Task { await presentViewModel(isLoading: false) }
            return
        }
        Task { await presentViewModel(isLoading: true) }
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            do {
                searchResults = try await interactor.searchMovies(query: self.query)
                await presentViewModel(isLoading: false)
            } catch {
                await presentError((error as? LocalizedError)?.errorDescription ?? "Search failed.")
            }
        }
    }

    public func didSelectRow(at index: Int) {
        let movieId: Int
        if query.isEmpty {
            guard trending.indices.contains(index) else { return }
            movieId = trending[index].id
        } else {
            guard searchResults.indices.contains(index) else { return }
            movieId = searchResults[index].id
        }
        guard let viewController = router.sourceViewController else { return }
        Task { @MainActor in
            router.showMovieDetail(movieId: movieId, from: viewController)
        }
    }

    @MainActor
    private func presentViewModel(isLoading: Bool) {
        view?.show(viewModel: makeViewModel(isLoading: isLoading))
    }

    @MainActor
    private func presentError(_ message: String) {
        view?.show(errorMessage: message)
    }

    private func makeViewModel(isLoading: Bool) -> SearchViewModel {
        if query.isEmpty {
            let rows = trending.map { movie -> SearchViewModel.Row in
                let posters = trending.shuffled().prefix(3).map { TMDBImageURL.poster(path: $0.posterPath) }
                return .trending(SearchViewModel.TrendingRow(
                    movieId: movie.id,
                    title: movie.title,
                    year: movie.releaseYear,
                    tagline: String((movie.overview ?? "").prefix(80)),
                    ratingText: String(format: "%.1f", movie.voteAverage ?? 0),
                    posterURLs: Array(posters)
                ))
            }
            return SearchViewModel(rows: rows, isSearching: false, isLoading: isLoading)
        }
        let rows = searchResults.map { movie in
            SearchViewModel.Row.searchResult(SearchViewModel.SearchRow(
                movieId: movie.id,
                title: movie.title,
                year: movie.releaseYear,
                posterURL: TMDBImageURL.poster(path: movie.posterPath)
            ))
        }
        return SearchViewModel(rows: rows, isSearching: true, isLoading: isLoading)
    }
}
