import Foundation
import NetworkKit
import UIComponentKit
import UIKit

public final class HomePresenter: HomePresenting {
    public weak var view: HomeView?

    private let interactor: HomeInteracting
    private let router: HomeRouting

    private var trending: [Movie] = []
    private var genres: [Genre] = []
    private var movies: [Movie] = []
    private var selectedGenreId: Int?
    private var heroIndex = 0
    private var isLoadingMore = false

    public init(interactor: HomeInteracting, router: HomeRouting) {
        self.interactor = interactor
        self.router = router
    }

    public func viewDidLoad() {
        Task { await load() }
    }

    public func refreshMovies() {
        Task { await load() }
    }

    public func viewDidScrollNearBottom() {
        guard !isLoadingMore else { return }
        isLoadingMore = true
        Task {
            await presentViewModel()
            await presentGridLoadingFooter(true)
            do {
                let more = try await interactor.loadMoreMovies()
                movies.append(contentsOf: more)
                isLoadingMore = false
                await appendMovies(more.map(mapMovie))
                await presentGridLoadingFooter(false)
            } catch {
                isLoadingMore = false
                await presentGridLoadingFooter(false)
                await presentError((error as? LocalizedError)?.errorDescription ?? "Failed to load more.")
            }
        }
    }

    public func didSelectHeroPage(_ index: Int) {
        heroIndex = index
        Task { await presentViewModel() }
    }

    public func didTapWatchTrailer() {
        guard trending.indices.contains(heroIndex),
              let viewController = router.sourceViewController else { return }
        let movie = trending[heroIndex]
        Task {
            do {
                if let url = try await interactor.trailerURL(for: movie.id) {
                    await presentTrailer(url: url, from: viewController)
                } else {
                    await presentError("Trailer not available for this movie.")
                }
            } catch {
                await presentError((error as? LocalizedError)?.errorDescription ?? "Trailer unavailable.")
            }
        }
    }

    public func didTapMovie(at index: Int) {
        guard movies.indices.contains(index),
              let viewController = router.sourceViewController else { return }
        Task { @MainActor in
            router.showMovieDetail(movieId: movies[index].id, from: viewController)
        }
    }

    public func didTapTopTen(at index: Int) {
        guard trending.indices.contains(index),
              let viewController = router.sourceViewController else { return }
        Task { @MainActor in
            router.showMovieDetail(movieId: trending[index].id, from: viewController)
        }
    }

    public func didSelectGenreChip(at index: Int) {
        guard genres.indices.contains(index) else { return }
        let genre = genres[index]
        if selectedGenreId == genre.id {
            selectedGenreId = nil
            interactor.resetPagination(genreId: nil)
        } else {
            selectedGenreId = genre.id
            interactor.resetPagination(genreId: genre.id)
        }
        reloadMoviesOnly()
    }

    private func reloadMoviesOnly() {
        Task {
            do {
                let result = try await interactor.loadInitialData()
                movies = result.movies.results
                genres = result.genres
                await presentViewModel()
            } catch {
                await presentError((error as? LocalizedError)?.errorDescription ?? "Failed to filter movies.")
            }
        }
    }

    private func load() async {
        do {
            let result = try await interactor.loadInitialData()
            trending = result.trending
            genres = result.genres
            movies = result.movies.results
            selectedGenreId = result.selectedGenreId
            await presentViewModel()
        } catch {
            await presentError((error as? LocalizedError)?.errorDescription ?? "Failed to load home.")
        }
    }

    @MainActor
    private func presentViewModel() {
        view?.show(viewModel: makeViewModel())
    }

    @MainActor
    private func presentError(_ message: String) {
        view?.show(errorMessage: message)
    }

    @MainActor
    private func presentGridLoadingFooter(_ visible: Bool) {
        view?.showGridLoadingFooter(visible)
    }

    @MainActor
    private func appendMovies(_ items: [HomeViewModel.MovieItem]) {
        view?.appendMovies(items)
    }

    @MainActor
    private func presentTrailer(url: URL, from viewController: UIViewController) {
        router.openURL(url, from: viewController)
    }

    private func makeViewModel() -> HomeViewModel {
        HomeViewModel(
            heroItems: trending.prefix(5).map {
                HomeViewModel.HeroItem(
                    movieId: $0.id,
                    title: $0.title,
                    backdropURL: TMDBImageURL.backdrop(path: $0.backdropPath),
                    hasTrailer: true
                )
            },
            heroIndex: heroIndex,
            topTen: Array(trending.prefix(10)).map(mapMovie),
            movies: movies.map(mapMovie),
            genreChips: genres.map {
                HomeViewModel.GenreChipItem(id: $0.id, name: $0.name, isSelected: selectedGenreId == $0.id)
            },
            isLoadingMore: isLoadingMore
        )
    }

    private func mapMovie(_ movie: Movie) -> HomeViewModel.MovieItem {
        HomeViewModel.MovieItem(
            movieId: movie.id,
            title: movie.title,
            year: movie.releaseYear,
            ratingText: String(format: "%.1f", movie.voteAverage ?? 0),
            posterURL: TMDBImageURL.poster(path: movie.posterPath)
        )
    }
}
