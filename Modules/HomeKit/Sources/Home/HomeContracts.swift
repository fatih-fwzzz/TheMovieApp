import UIKit
import NetworkKit

public protocol HomeView: AnyObject {
    func show(viewModel: HomeViewModel)
    func show(errorMessage: String)
    func appendMovies(_ items: [HomeViewModel.MovieItem])
    func showGridLoadingFooter(_ visible: Bool)
}

public protocol HomePresenting: AnyObject {
    func viewDidLoad()
    func viewDidScrollNearBottom()
    func didSelectHeroPage(_ index: Int)
    func didTapWatchTrailer()
    func didTapMovie(at index: Int)
    func didTapTopTen(at index: Int)
    func didSelectGenreChip(at index: Int)
    func refreshMovies()
}

public protocol HomeInteracting: AnyObject {
    func loadInitialData() async throws -> HomeInteractorResult
    func loadMoreMovies() async throws -> [Movie]
    func trailerURL(for movieId: Int) async throws -> URL?
    func resetPagination(genreId: Int?)
}

public protocol HomeRouting: AnyObject {
    var sourceViewController: UIViewController? { get }
    func showMovieDetail(movieId: Int, from viewController: UIViewController)
    func openURL(_ url: URL, from viewController: UIViewController)
}

public struct HomeViewModel {
    public struct HeroItem {
        public let movieId: Int
        public let title: String
        public let backdropURL: URL?
        public let hasTrailer: Bool
    }

    public struct MovieItem {
        public let movieId: Int
        public let title: String
        public let year: String
        public let ratingText: String
        public let posterURL: URL?
    }

    public struct GenreChipItem {
        public let id: Int
        public let name: String
        public let isSelected: Bool
    }

    public let heroItems: [HeroItem]
    public let heroIndex: Int
    public let topTen: [MovieItem]
    public let movies: [MovieItem]
    public let genreChips: [GenreChipItem]
    public let isLoadingMore: Bool
}

public struct HomeInteractorResult {
    public let trending: [Movie]
    public let genres: [Genre]
    public let movies: PaginatedMoviesResponse
    public let selectedGenreId: Int?
}
