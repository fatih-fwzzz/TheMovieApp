import NetworkKit

public protocol ReviewsPresenting: AnyObject {
    func viewDidAppear()
    func viewDidScrollNearBottom()
    func didTapBack()
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
    public struct ReviewItem: Identifiable {
        public var id: String { "\(author)-\(dateText)" }
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
