import UIKit

public final class FavoritesRouter: FavoritesRouting {
    public weak var viewController: UIViewController?
    private weak var routing: FavoritesRouting?

    public init(routing: FavoritesRouting) {
        self.routing = routing
    }

    public func showMovieDetail(movieId: Int, from viewController: UIViewController) {
        routing?.showMovieDetail(movieId: movieId, from: viewController)
    }

    public func switchToHomeTab() {
        routing?.switchToHomeTab()
    }
}
