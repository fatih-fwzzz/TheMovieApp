import Foundation

public final class ReviewsInteractor: ReviewsInteracting {
    private let movieService: MovieServiceProtocol
    private var currentPage = 1
    private var isFetching = false
    public private(set) var hasReachedEnd = false

    public init(movieService: MovieServiceProtocol) {
        self.movieService = movieService
    }

    public func fetchInitial(movieId: Int) async throws -> ReviewsInteractorPayload {
        currentPage = 1
        hasReachedEnd = false
        async let movie = movieService.fetchMovieDetail(id: movieId)
        async let reviews = movieService.fetchReviews(movieId: movieId, page: 1)
        let (detail, page) = try await (movie, reviews)
        hasReachedEnd = page.page >= page.totalPages
        return ReviewsInteractorPayload(movie: detail, reviews: page)
    }

    public func fetchNextPage(movieId: Int) async throws -> [Review] {
        guard !isFetching, !hasReachedEnd else { return [] }
        isFetching = true
        defer { isFetching = false }
        currentPage += 1
        let response = try await movieService.fetchReviews(movieId: movieId, page: currentPage)
        hasReachedEnd = response.page >= response.totalPages
        return response.results
    }
}
