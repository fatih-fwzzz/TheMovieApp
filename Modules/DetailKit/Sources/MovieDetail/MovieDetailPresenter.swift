import Foundation
import Combine
import UIKit
import NetworkKit
import UIComponentKit

public final class MovieDetailPresenter: ObservableObject, MovieDetailPresenting {
    @Published public private(set) var viewModel = MovieDetailViewModel(
        title: "",
        overview: "",
        ratingText: "",
        year: "",
        runtimeText: "",
        genres: [],
        backdropURL: nil,
        posterURL: nil,
        trailerURL: nil,
        cast: [],
        isOverviewExpanded: false,
        isLoading: true,
        isFavorite: false,
        errorMessage: nil
    )

    private let interactor: MovieDetailInteracting
    private let router: MovieDetailRouting
    private let movieId: Int
    private weak var viewController: UIViewController?
    private var loadedDetail: MovieDetail?

    public init(movieId: Int, interactor: MovieDetailInteracting, router: MovieDetailRouting) {
        self.movieId = movieId
        self.interactor = interactor
        self.router = router
    }

    public func attach(viewController: UIViewController) {
        self.viewController = viewController
    }

    public func viewDidAppear() {
        Task { await load() }
    }

    public func didTapBack() {
        guard let viewController else { return }
        router.dismiss(from: viewController)
    }

    public func didTapWatchTrailer() {
        guard let url = viewModel.trailerURL, let viewController else { return }
        router.openURL(url, from: viewController)
    }

    public func didTapViewReviews() {
        guard let viewController else { return }
        router.showReviews(movieId: movieId, movieTitle: viewModel.title, from: viewController)
    }

    public func didToggleOverviewExpanded() {
        viewModel = updatedViewModel(isOverviewExpanded: !viewModel.isOverviewExpanded)
    }

    public func didTapFavorite() {
        guard let loadedDetail else { return }
        interactor.toggleFavorite(loadedDetail)
        viewModel = updatedViewModel(isFavorite: interactor.isFavorite(movieId: movieId))
    }

    private func load() async {
        viewModel = updatedViewModel(isLoading: true)
        do {
            async let detail = interactor.fetchDetail(movieId: movieId)
            async let trailer = interactor.fetchTrailer(movieId: movieId)
            async let cast = interactor.fetchCast(movieId: movieId)
            let (movie, trailerURL, castMembers) = try await (detail, trailer, cast)
            loadedDetail = movie
            let year = movie.releaseDate.map { String($0.prefix(4)) } ?? "—"
            viewModel = MovieDetailViewModel(
                title: movie.title,
                overview: movie.overview,
                ratingText: String(format: "%.1f", movie.voteAverage),
                year: year,
                runtimeText: "\(movie.runtime ?? 0) min",
                genres: movie.genres.map(\.name),
                backdropURL: TMDBImageURL.backdrop(path: movie.backdropPath),
                posterURL: TMDBImageURL.poster(path: movie.posterPath),
                trailerURL: trailerURL,
                cast: castMembers.prefix(10).map {
                    MovieDetailViewModel.CastItem(
                        name: $0.name,
                        character: $0.character,
                        imageURL: TMDBImageURL.profile(path: $0.profilePath)
                    )
                },
                isOverviewExpanded: false,
                isLoading: false,
                isFavorite: interactor.isFavorite(movieId: movieId),
                errorMessage: nil
            )
        } catch {
            viewModel = updatedViewModel(
                isLoading: false,
                errorMessage: (error as? LocalizedError)?.errorDescription ?? "Failed to load movie."
            )
        }
    }

    private func updatedViewModel(
        isOverviewExpanded: Bool? = nil,
        isLoading: Bool? = nil,
        isFavorite: Bool? = nil,
        errorMessage: String?? = nil
    ) -> MovieDetailViewModel {
        MovieDetailViewModel(
            title: viewModel.title,
            overview: viewModel.overview,
            ratingText: viewModel.ratingText,
            year: viewModel.year,
            runtimeText: viewModel.runtimeText,
            genres: viewModel.genres,
            backdropURL: viewModel.backdropURL,
            posterURL: viewModel.posterURL,
            trailerURL: viewModel.trailerURL,
            cast: viewModel.cast,
            isOverviewExpanded: isOverviewExpanded ?? viewModel.isOverviewExpanded,
            isLoading: isLoading ?? viewModel.isLoading,
            isFavorite: isFavorite ?? viewModel.isFavorite,
            errorMessage: errorMessage ?? viewModel.errorMessage
        )
    }
}
