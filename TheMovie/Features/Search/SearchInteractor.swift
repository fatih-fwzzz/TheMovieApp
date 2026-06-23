import Foundation

public final class SearchInteractor: SearchInteracting {
    private let movieService: MovieServiceProtocol

    public init(movieService: MovieServiceProtocol) {
        self.movieService = movieService
    }

    public func fetchTrending() async throws -> [Movie] {
        try await movieService.fetchTrendingWeek()
    }

    public func searchMovies(query: String) async throws -> [Movie] {
        let response = try await movieService.searchMovies(query: query, page: 1)
        return response.results
    }
}
