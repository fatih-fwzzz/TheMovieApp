import Foundation

public final class MovieDetailInteractor: MovieDetailInteracting {
    private let movieService: MovieServiceProtocol
    private let favoritesStore: FavoritesStoreProtocol

    public init(movieService: MovieServiceProtocol, favoritesStore: FavoritesStoreProtocol) {
        self.movieService = movieService
        self.favoritesStore = favoritesStore
    }

    public func fetchDetail(movieId: Int) async throws -> MovieDetail {
        try await movieService.fetchMovieDetail(id: movieId)
    }

    public func fetchTrailer(movieId: Int) async throws -> URL? {
        guard let key = try await movieService.fetchTrailerKey(movieId: movieId) else { return nil }
        return URL(string: "https://www.youtube.com/watch?v=\(key)")
    }

    public func fetchCast(movieId: Int) async throws -> [CastMember] {
        try await movieService.fetchCredits(movieId: movieId)
    }

    public func fetchReviews(movieId: Int) async throws -> PaginatedReviewsResponse {
        try await movieService.fetchReviews(movieId: movieId, page: 1)
    }

    public func isFavorite(movieId: Int) -> Bool {
        favoritesStore.isFavorite(movieId: movieId)
    }

    public func toggleFavorite(_ movie: MovieDetail) {
        if favoritesStore.isFavorite(movieId: movie.id) {
            favoritesStore.remove(movieId: movie.id)
        } else {
            let year = movie.releaseDate.map { String($0.prefix(4)) } ?? "—"
            favoritesStore.add(MovieSnapshot(
                id: movie.id,
                title: movie.title,
                posterPath: movie.posterPath,
                releaseYear: year,
                rating: movie.voteAverage
            ))
        }
    }
}
