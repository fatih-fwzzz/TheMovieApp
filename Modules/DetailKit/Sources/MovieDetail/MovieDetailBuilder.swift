import UIKit
import NetworkKit

public enum MovieDetailBuilder {
    public static func build(movieId: Int, dependencies: FeatureDependencies, routing: MovieDetailRouting) -> UIViewController {
        let interactor = MovieDetailInteractor(
            movieService: dependencies.movieService,
            favoritesStore: dependencies.favoritesStore
        )
        let router = MovieDetailRouter(routing: routing)
        let presenter = MovieDetailPresenter(movieId: movieId, interactor: interactor, router: router)
        let viewController = MovieDetailViewController(presenter: presenter)
        presenter.view = viewController
        presenter.attach(viewController: viewController)
        router.viewController = viewController
        return viewController
    }
}
