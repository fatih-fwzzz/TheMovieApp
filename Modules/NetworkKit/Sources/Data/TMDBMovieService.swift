import Foundation

public protocol MovieServiceProtocol: Sendable {
    func fetchGenres() async throws -> [Genre]
    func fetchTrendingWeek() async throws -> [Movie]
    func discoverMovies(genreId: Int?, page: Int) async throws -> PaginatedMoviesResponse
    func searchMovies(query: String, page: Int) async throws -> PaginatedMoviesResponse
    func fetchMovieDetail(id: Int) async throws -> MovieDetail
    func fetchReviews(movieId: Int, page: Int) async throws -> PaginatedReviewsResponse
    func fetchTrailerKey(movieId: Int) async throws -> String?
    func fetchCredits(movieId: Int) async throws -> [CastMember]
}

public final class TMDBMovieService: MovieServiceProtocol, @unchecked Sendable {
    private let network: NetworkServiceProtocol

    public init(network: NetworkServiceProtocol) {
        self.network = network
    }

    public func fetchGenres() async throws -> [Genre] {
        let response: GenreListResponse = try await network.request(GenreListResponse.self, endpoint: .genreList)
        return response.genres
    }

    public func fetchTrendingWeek() async throws -> [Movie] {
        let response: PaginatedMoviesResponse = try await network.request(PaginatedMoviesResponse.self, endpoint: .trendingWeek)
        return response.results
    }

    public func discoverMovies(genreId: Int?, page: Int) async throws -> PaginatedMoviesResponse {
        try await network.request(PaginatedMoviesResponse.self, endpoint: .discoverMovies(genreId: genreId, page: page))
    }

    public func searchMovies(query: String, page: Int) async throws -> PaginatedMoviesResponse {
        try await network.request(PaginatedMoviesResponse.self, endpoint: .searchMovies(query: query, page: page))
    }

    public func fetchMovieDetail(id: Int) async throws -> MovieDetail {
        try await network.request(MovieDetail.self, endpoint: .movieDetail(id: id))
    }

    public func fetchReviews(movieId: Int, page: Int) async throws -> PaginatedReviewsResponse {
        try await network.request(PaginatedReviewsResponse.self, endpoint: .movieReviews(id: movieId, page: page))
    }

    public func fetchTrailerKey(movieId: Int) async throws -> String? {
        let response: VideosResponse = try await network.request(VideosResponse.self, endpoint: .movieVideos(id: movieId))
        return response.results.first { $0.site == "YouTube" && $0.type == "Trailer" }?.key
    }

    public func fetchCredits(movieId: Int) async throws -> [CastMember] {
        let response: CreditsResponse = try await network.request(CreditsResponse.self, endpoint: .movieCredits(id: movieId))
        return response.cast
    }
}
