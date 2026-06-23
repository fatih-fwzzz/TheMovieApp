import UIKit

public enum FavoritesBuilder {
    public static func build(dependencies: FeatureDependencies, routing: FavoritesRouting) -> UIViewController {
        let interactor = FavoritesInteractor(store: dependencies.favoritesStore)
        let router = FavoritesRouter(routing: routing)
        let presenter = FavoritesPresenter(interactor: interactor, router: router)
        let viewController = FavoritesViewController(presenter: presenter)
        presenter.view = viewController
        router.viewController = viewController
        return viewController
    }
}
