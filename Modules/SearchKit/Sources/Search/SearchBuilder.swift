import UIKit
import NetworkKit

public enum SearchBuilder {
    public static func build(dependencies: FeatureDependencies, routing: SearchRouting) -> UIViewController {
        let interactor = SearchInteractor(movieService: dependencies.movieService)
        let router = SearchRouter(routing: routing)
        let presenter = SearchPresenter(interactor: interactor, router: router)
        let viewController = SearchViewController(presenter: presenter)
        presenter.view = viewController
        router.viewController = viewController
        return viewController
    }
}
