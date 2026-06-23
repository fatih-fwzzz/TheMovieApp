import UIKit
import SwiftUI
import NetworkKit

public enum MovieDetailBuilder {
    public static func build(movieId: Int, dependencies: FeatureDependencies, routing: MovieDetailRouting) -> UIViewController {
        let interactor = MovieDetailInteractor(
            movieService: dependencies.movieService,
            favoritesStore: dependencies.favoritesStore
        )
        let router = MovieDetailRouter(routing: routing)
        let presenter = MovieDetailPresenter(movieId: movieId, interactor: interactor, router: router)
        let view = MovieDetailView(presenter: presenter)
        let hosting = UIHostingController(rootView: view)
        hosting.view.backgroundColor = UIColor(red: 0.075, green: 0.075, blue: 0.075, alpha: 1)
        presenter.attach(viewController: hosting)
        router.viewController = hosting
        return hosting
    }
}
