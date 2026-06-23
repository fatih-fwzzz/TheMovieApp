import Foundation
import NetworkKit
import UIComponentKit

public final class ReviewsPresenter: ReviewsPresenting {
    public weak var view: ReviewsView?

    private let interactor: ReviewsInteracting
    private let movieId: Int
    private var reviews: [Review] = []
    private var movieTitle = ""
    private var moviePosterURL: URL?
    private var ratingText = ""
    private var reviewCountText = ""
    private var isLoadingMore = false

    public init(movieId: Int, interactor: ReviewsInteracting) {
        self.movieId = movieId
        self.interactor = interactor
    }

    public func viewDidLoad() {
        Task {
            do {
                let payload = try await interactor.fetchInitial(movieId: movieId)
                movieTitle = payload.movie.title
                moviePosterURL = TMDBImageURL.poster(path: payload.movie.posterPath)
                ratingText = String(format: "%.1f", payload.movie.voteAverage)
                reviewCountText = "(\(payload.reviews.results.count)+)"
                reviews = payload.reviews.results
                await presentViewModel(makeViewModel())
            } catch {
                await presentError((error as? LocalizedError)?.errorDescription ?? "Failed to load reviews.")
            }
        }
    }

    public func viewDidScrollNearBottom() {
        guard !isLoadingMore, !interactor.hasReachedEnd else { return }
        isLoadingMore = true
        Task {
            await presentLoadingFooter(true)
            do {
                let more = try await interactor.fetchNextPage(movieId: movieId)
                reviews.append(contentsOf: more)
                isLoadingMore = false
                await appendReviews(more.map(mapReview))
                await presentLoadingFooter(false)
            } catch {
                isLoadingMore = false
                await presentLoadingFooter(false)
            }
        }
    }

    @MainActor
    private func presentViewModel(_ viewModel: ReviewsViewModel) {
        view?.show(viewModel: viewModel)
    }

    @MainActor
    private func presentError(_ message: String) {
        view?.show(errorMessage: message)
    }

    @MainActor
    private func appendReviews(_ items: [ReviewsViewModel.ReviewItem]) {
        view?.appendReviews(items)
    }

    @MainActor
    private func presentLoadingFooter(_ visible: Bool) {
        view?.showLoadingFooter(visible)
    }

    private func makeViewModel() -> ReviewsViewModel {
        ReviewsViewModel(
            movieTitle: movieTitle,
            moviePosterURL: moviePosterURL,
            ratingText: ratingText,
            reviewCountText: reviewCountText,
            reviews: reviews.map(mapReview),
            isLoadingMore: isLoadingMore
        )
    }

    private func mapReview(_ review: Review) -> ReviewsViewModel.ReviewItem {
        ReviewsViewModel.ReviewItem(
            author: review.author,
            content: review.displayContent,
            dateText: formatDate(review.createdAt),
            ratingText: review.rating.map { String(format: "%.1f", $0) } ?? "—",
            avatarURL: TMDBImageURL.profile(path: review.authorDetails?.avatarPath, size: "w45"),
            initial: String(review.author.prefix(1)).uppercased()
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
