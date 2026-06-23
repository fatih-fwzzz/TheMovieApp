import UIKit

public final class MovieDetailRouter: MovieDetailRouting {
    public weak var viewController: UIViewController?
    private weak var routing: MovieDetailRouting?

    public init(routing: MovieDetailRouting) {
        self.routing = routing
    }

    public func dismiss(from viewController: UIViewController) {
        routing?.dismiss(from: viewController)
    }

    public func openURL(_ url: URL, from viewController: UIViewController) {
        routing?.openURL(url, from: viewController)
    }

    public func showReviews(movieId: Int, movieTitle: String, from viewController: UIViewController) {
        routing?.showReviews(movieId: movieId, movieTitle: movieTitle, from: viewController)
    }
}
