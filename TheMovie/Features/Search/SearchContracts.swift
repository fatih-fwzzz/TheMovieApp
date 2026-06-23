import UIKit

public protocol SearchView: AnyObject {
    func show(viewModel: SearchViewModel)
    func show(errorMessage: String)
}

public protocol SearchPresenting: AnyObject {
    func viewDidLoad()
    func searchQueryChanged(_ query: String)
    func didSelectRow(at index: Int)
}

public protocol SearchInteracting: AnyObject {
    func fetchTrending() async throws -> [Movie]
    func searchMovies(query: String) async throws -> [Movie]
}

public protocol SearchRouting: AnyObject {
    var sourceViewController: UIViewController? { get }
    func showMovieDetail(movieId: Int, from viewController: UIViewController)
}

public struct SearchViewModel {
    public enum Row {
        case trending(TrendingRow)
        case searchResult(SearchRow)
    }

    public struct TrendingRow {
        public let movieId: Int
        public let title: String
        public let year: String
        public let ratingText: String
        public let posterURL: URL?
    }

    public struct SearchRow {
        public let movieId: Int
        public let title: String
        public let year: String
        public let posterURL: URL?
    }

    public let rows: [Row]
    public let isSearching: Bool
    public let isLoading: Bool
}
