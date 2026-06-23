import XCTest
import NetworkKit

final class NetworkKitTests: XCTestCase {
    func test_tmdbEndpoint_genreListURL() {
        let url = TMDBEndpoint.genreList.url
        XCTAssertTrue(url?.absoluteString.contains("/genre/movie/list") ?? false)
    }

    func test_tmdbEndpoint_discoverWithGenre() {
        let url = TMDBEndpoint.discoverMovies(genreId: 28, page: 2).url
        let string = url?.absoluteString ?? ""
        XCTAssertTrue(string.contains("with_genres=28"))
        XCTAssertTrue(string.contains("page=2"))
    }

    func test_networkError_descriptions() {
        XCTAssertEqual(NetworkError.serverError(statusCode: 401).errorDescription, "Server returned an error (HTTP 401).")
        XCTAssertEqual(NetworkError.noInternetConnection.errorDescription, "No internet connection. Please try again.")
    }

    func test_favoritesStore_addAndRemove() {
        let store = FavoritesStore(defaults: UserDefaults(suiteName: "test.favorites")!)
        let snapshot = MovieSnapshot(id: 99, title: "Test", posterPath: nil, releaseYear: "2024", rating: 8.0)
        store.add(snapshot)
        XCTAssertTrue(store.isFavorite(movieId: 99))
        store.remove(movieId: 99)
        XCTAssertFalse(store.isFavorite(movieId: 99))
    }
}
