import Foundation
import UIKit

public final class MovieDetailPresenter: MovieDetailPresenting {
    public weak var view: MovieDetailView?

    private let interactor: MovieDetailInteracting
    private let router: MovieDetailRouting
    private let movieId: Int
    private weak var viewController: UIViewController?
    private var loadedDetail: MovieDetail?
    private var viewModel = MovieDetailViewModel(
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
        previewReviews: [],
        isOverviewExpanded: false,
        isLoading: true,
        isFavorite: false,
        errorMessage: nil
    )

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
        Task { @MainActor in presentViewModel() }
    }

    public func didTapFavorite() {
        guard let loadedDetail else { return }
        interactor.toggleFavorite(loadedDetail)
        viewModel = updatedViewModel(isFavorite: interactor.isFavorite(movieId: movieId))
        Task { @MainActor in presentViewModel() }
    }

    private func load() async {
        viewModel = updatedViewModel(isLoading: true)
        await MainActor.run { presentViewModel() }
        do {
            async let detail = interactor.fetchDetail(movieId: movieId)
            async let trailer = interactor.fetchTrailer(movieId: movieId)
            async let cast = interactor.fetchCast(movieId: movieId)
            async let reviews = interactor.fetchReviews(movieId: movieId)
            let (movie, trailerURL, castMembers, reviewsResponse) = try await (detail, trailer, cast, reviews)
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
                previewReviews: reviewsResponse.results.prefix(2).map(mapReview),
                isOverviewExpanded: false,
                isLoading: false,
                isFavorite: interactor.isFavorite(movieId: movieId),
                errorMessage: nil
            )
            await MainActor.run { presentViewModel() }
        } catch {
            viewModel = updatedViewModel(
                isLoading: false,
                errorMessage: (error as? LocalizedError)?.errorDescription ?? "Failed to load movie."
            )
            await MainActor.run {
                presentViewModel()
                presentError(viewModel.errorMessage ?? "Failed to load movie.")
            }
        }
    }

    @MainActor
    private func presentViewModel() {
        view?.show(viewModel: viewModel)
    }

    @MainActor
    private func presentError(_ message: String) {
        view?.show(errorMessage: message)
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
            previewReviews: viewModel.previewReviews,
            isOverviewExpanded: isOverviewExpanded ?? viewModel.isOverviewExpanded,
            isLoading: isLoading ?? viewModel.isLoading,
            isFavorite: isFavorite ?? viewModel.isFavorite,
            errorMessage: errorMessage ?? viewModel.errorMessage
        )
    }

    private func mapReview(_ review: Review) -> MovieDetailViewModel.ReviewItem {
        MovieDetailViewModel.ReviewItem(
            id: "\(review.author)-\(review.createdAt)",
            author: review.author,
            content: review.displayContent,
            dateText: formatDate(review.createdAt),
            ratingText: review.rating.map { String(format: "%.1f", $0) } ?? "—",
            avatarURL: TMDBImageURL.profile(path: review.authorDetails?.avatarPath, size: "w45")
        )
    }

    private func formatDate(_ iso: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: iso) else { return iso }
        let rel = RelativeDateTimeFormatter()
        rel.unitsStyle = .short
        return rel.localizedString(for: date, relativeTo: Date())
    }
}
