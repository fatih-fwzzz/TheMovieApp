import UIKit
import SwiftUI

public enum ReviewsBuilder {
    public static func build(movieId: Int, dependencies: FeatureDependencies) -> UIViewController {
        let interactor = ReviewsInteractor(movieService: dependencies.movieService)
        let presenter = ReviewsPresenter(movieId: movieId, interactor: interactor)
        let hosting = UIHostingController(rootView: ReviewsView(presenter: presenter))
        hosting.view.backgroundColor = AppColor.background
        presenter.attach(viewController: hosting)
        return hosting
    }
}
