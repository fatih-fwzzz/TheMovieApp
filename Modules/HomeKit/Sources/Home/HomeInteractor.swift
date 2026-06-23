import Foundation
import NetworkKit

public final class HomeInteractor: HomeInteracting {
    private let movieService: MovieServiceProtocol
    private(set) var currentPage = 1
    private(set) var isFetching = false
    private(set) var hasReachedEnd = false
    private var genreId: Int?

    private static let displayedGenres: [(displayName: String, apiName: String)] = [
        ("Action", "Action"),
        ("Horror", "Horror"),
        ("Sci-Fi", "Science Fiction"),
        ("Comedy", "Comedy"),
        ("Drama", "Drama")
    ]

    public init(movieService: MovieServiceProtocol) {
        self.movieService = movieService
    }

    public func loadInitialData() async throws -> HomeInteractorResult {
        resetPagination(genreId: genreId)
        async let trending = movieService.fetchTrendingWeek()
        async let genres = movieService.fetchGenres()
        async let movies = movieService.discoverMovies(genreId: genreId, page: currentPage)
        let (trendingResult, genresResult, moviesResult) = try await (trending, genres, movies)
        hasReachedEnd = moviesResult.page >= moviesResult.totalPages
        let filteredGenres = Self.displayedGenres.compactMap { entry -> Genre? in
            guard let genre = genresResult.first(where: { $0.name == entry.apiName }) else { return nil }
            return Genre(id: genre.id, name: entry.displayName)
        }
        return HomeInteractorResult(
            trending: trendingResult,
            genres: filteredGenres,
            movies: moviesResult,
            selectedGenreId: genreId
        )
    }

    public func loadMoreMovies() async throws -> [Movie] {
        guard !isFetching, !hasReachedEnd else { return [] }
        isFetching = true
        defer { isFetching = false }
        currentPage += 1
        let response = try await movieService.discoverMovies(genreId: genreId, page: currentPage)
        hasReachedEnd = response.page >= response.totalPages
        return response.results
    }

    public func trailerURL(for movieId: Int) async throws -> URL? {
        guard let key = try await movieService.fetchTrailerKey(movieId: movieId) else { return nil }
        return URL(string: "https://www.youtube.com/watch?v=\(key)")
    }

    public func resetPagination(genreId: Int?) {
        self.genreId = genreId
        currentPage = 1
        hasReachedEnd = false
        isFetching = false
    }
}
