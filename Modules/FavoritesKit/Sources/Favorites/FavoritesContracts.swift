import UIKit
import NetworkKit

public protocol FavoritesView: AnyObject {
    func show(viewModel: FavoritesViewModel)
    func show(errorMessage: String)
    func removeItem(at index: Int)
}

public protocol FavoritesPresenting: AnyObject {
    func viewDidLoad()
    func searchQueryChanged(_ query: String)
    func didTapMovie(at index: Int)
    func didToggleFavorite(at index: Int)
    func didTapBrowseMovies()
}

public protocol FavoritesInteracting: AnyObject {
    func fetchFavorites() -> [MovieSnapshot]
    func removeFavorite(movieId: Int)
}

public protocol FavoritesRouting: AnyObject {
    func showMovieDetail(movieId: Int, from viewController: UIViewController)
    func switchToHomeTab()
}

public struct FavoritesViewModel {
    public struct Item {
        public let movieId: Int
        public let title: String
        public let year: String
        public let ratingText: String
        public let posterURL: URL?
    }

    public let items: [Item]
    public let countText: String
    public let isEmpty: Bool
}
