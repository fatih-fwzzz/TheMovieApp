import Foundation
import Combine
import UIKit

public final class ReviewsPresenter: ObservableObject, ReviewsPresenting {
    @Published public private(set) var viewModel = ReviewsViewModel(
        movieTitle: "",
        moviePosterURL: nil,
        ratingText: "",
        reviewCountText: "",
        reviews: [],
        isLoadingMore: false
    )
    @Published public var alertMessage: String?

    private let interactor: ReviewsInteracting
    private let movieId: Int
    private weak var viewController: UIViewController?
    private var reviews: [Review] = []
    private var isLoadingMore = false

    public init(movieId: Int, interactor: ReviewsInteracting) {
        self.movieId = movieId
        self.interactor = interactor
    }

    public func attach(viewController: UIViewController) {
        self.viewController = viewController
    }

    public func viewDidAppear() {
        Task {
            do {
                let payload = try await interactor.fetchInitial(movieId: movieId)
                reviews = payload.reviews.results
                await MainActor.run {
                    updateViewModel(
                        movieTitle: payload.movie.title,
                        moviePosterURL: TMDBImageURL.poster(path: payload.movie.posterPath),
                        ratingText: String(format: "%.1f", payload.movie.voteAverage),
                        reviewCountText: "(\(payload.reviews.results.count)+)"
                    )
                }
            } catch {
                await MainActor.run {
                    presentError((error as? LocalizedError)?.errorDescription ?? "Failed to load reviews.")
                }
            }
        }
    }

    public func viewDidScrollNearBottom() {
        guard !isLoadingMore, !interactor.hasReachedEnd else { return }
        isLoadingMore = true
        Task {
            await MainActor.run { setLoadingMore(true) }
            do {
                let more = try await interactor.fetchNextPage(movieId: movieId)
                reviews.append(contentsOf: more)
                isLoadingMore = false
                await MainActor.run {
                    updateViewModel()
                    setLoadingMore(false)
                }
            } catch {
                isLoadingMore = false
                await MainActor.run { setLoadingMore(false) }
            }
        }
    }

    public func didTapBack() {
        viewController?.navigationController?.popViewController(animated: true)
    }

    @MainActor
    private func updateViewModel(
        movieTitle: String? = nil,
        moviePosterURL: URL? = nil,
        ratingText: String? = nil,
        reviewCountText: String? = nil
    ) {
        viewModel = ReviewsViewModel(
            movieTitle: movieTitle ?? viewModel.movieTitle,
            moviePosterURL: moviePosterURL ?? viewModel.moviePosterURL,
            ratingText: ratingText ?? viewModel.ratingText,
            reviewCountText: reviewCountText ?? viewModel.reviewCountText,
            reviews: reviews.map(mapReview),
            isLoadingMore: isLoadingMore
        )
    }

    @MainActor
    private func setLoadingMore(_ loading: Bool) {
        isLoadingMore = loading
        viewModel = ReviewsViewModel(
            movieTitle: viewModel.movieTitle,
            moviePosterURL: viewModel.moviePosterURL,
            ratingText: viewModel.ratingText,
            reviewCountText: viewModel.reviewCountText,
            reviews: viewModel.reviews,
            isLoadingMore: loading
        )
    }

    @MainActor
    private func presentError(_ message: String) {
        alertMessage = message
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
