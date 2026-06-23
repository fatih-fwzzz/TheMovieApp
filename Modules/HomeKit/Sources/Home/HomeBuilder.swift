import UIKit
import NetworkKit

public enum HomeBuilder {
    public static func build(dependencies: FeatureDependencies, routing: HomeRouting) -> UIViewController {
        let interactor = HomeInteractor(movieService: dependencies.movieService)
        let router = HomeRouter(routing: routing)
        let presenter = HomePresenter(interactor: interactor, router: router)
        let viewController = HomeViewController(presenter: presenter)
        presenter.view = viewController
        router.viewController = viewController
        return viewController
    }
}
