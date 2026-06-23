import UIKit
import NetworkKit

public enum ReviewsBuilder {
    public static func build(movieId: Int, dependencies: FeatureDependencies) -> UIViewController {
        let interactor = ReviewsInteractor(movieService: dependencies.movieService)
        let presenter = ReviewsPresenter(movieId: movieId, interactor: interactor)
        let viewController = ReviewsViewController(presenter: presenter)
        presenter.view = viewController
        return viewController
    }
}
