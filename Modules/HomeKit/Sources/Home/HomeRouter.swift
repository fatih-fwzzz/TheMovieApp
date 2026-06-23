import UIKit

public final class HomeRouter: HomeRouting {
    public weak var viewController: UIViewController?
    private weak var routing: HomeRouting?

    public init(routing: HomeRouting) {
        self.routing = routing
    }

    public func showMovieDetail(movieId: Int, from viewController: UIViewController) {
        routing?.showMovieDetail(movieId: movieId, from: viewController)
    }

    public func openURL(_ url: URL, from viewController: UIViewController) {
        routing?.openURL(url, from: viewController)
    }
}
