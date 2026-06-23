import UIKit

public final class SearchRouter: SearchRouting {
    public weak var viewController: UIViewController?
    private weak var routing: SearchRouting?

    public init(routing: SearchRouting) {
        self.routing = routing
    }

    public func showMovieDetail(movieId: Int, from viewController: UIViewController) {
        routing?.showMovieDetail(movieId: movieId, from: viewController)
    }
}
