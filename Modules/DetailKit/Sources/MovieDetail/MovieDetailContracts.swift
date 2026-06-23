import UIKit
import NetworkKit

public protocol MovieDetailView: AnyObject {
    func show(viewModel: MovieDetailViewModel)
    func show(errorMessage: String)
}

public protocol MovieDetailPresenting: AnyObject {
    func viewDidAppear()
    func didTapBack()
    func didTapWatchTrailer()
    func didTapViewReviews()
    func didToggleOverviewExpanded()
    func didTapFavorite()
}

public protocol MovieDetailInteracting: AnyObject {
    func fetchDetail(movieId: Int) async throws -> MovieDetail
    func fetchTrailer(movieId: Int) async throws -> URL?
    func fetchCast(movieId: Int) async throws -> [CastMember]
    func fetchReviews(movieId: Int) async throws -> PaginatedReviewsResponse
    func isFavorite(movieId: Int) -> Bool
    func toggleFavorite(_ movie: MovieDetail)
}

public protocol MovieDetailRouting: AnyObject {
    func dismiss(from viewController: UIViewController)
    func openURL(_ url: URL, from viewController: UIViewController)
    func showReviews(movieId: Int, movieTitle: String, from viewController: UIViewController)
}

public struct MovieDetailViewModel {
    public struct CastItem {
        public let name: String
        public let character: String
        public let imageURL: URL?
    }

    public struct ReviewItem {
        public let id: String
        public let author: String
        public let content: String
        public let dateText: String
        public let ratingText: String
        public let avatarURL: URL?
    }

    public let title: String
    public let overview: String
    public let ratingText: String
    public let year: String
    public let runtimeText: String
    public let genres: [String]
    public let backdropURL: URL?
    public let posterURL: URL?
    public let trailerURL: URL?
    public let cast: [CastItem]
    public let previewReviews: [ReviewItem]
    public let isOverviewExpanded: Bool
    public let isLoading: Bool
    public let isFavorite: Bool
    public let errorMessage: String?
}
