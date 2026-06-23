import UIKit
import NetworkKit

public protocol ReviewsView: AnyObject {
    func show(viewModel: ReviewsViewModel)
    func show(errorMessage: String)
    func appendReviews(_ items: [ReviewsViewModel.ReviewItem])
    func showLoadingFooter(_ visible: Bool)
}

public protocol ReviewsPresenting: AnyObject {
    func viewDidLoad()
    func viewDidScrollNearBottom()
}

public protocol ReviewsInteracting: AnyObject {
    var hasReachedEnd: Bool { get }
    func fetchInitial(movieId: Int) async throws -> ReviewsInteractorPayload
    func fetchNextPage(movieId: Int) async throws -> [Review]
}

public struct ReviewsInteractorPayload {
    public let movie: MovieDetail
    public let reviews: PaginatedReviewsResponse
}

public struct ReviewsViewModel {
    public struct ReviewItem {
        public let author: String
        public let content: String
        public let dateText: String
        public let ratingText: String
        public let avatarURL: URL?
        public let initial: String
    }

    public let movieTitle: String
    public let moviePosterURL: URL?
    public let ratingText: String
    public let reviewCountText: String
    public let reviews: [ReviewItem]
    public let isLoadingMore: Bool
}
