import UIKit
import SafariServices
import Hero

final class AppNavigation: HomeRouting, SearchRouting, FavoritesRouting, MovieDetailRouting {
    weak var tabBarController: UITabBarController?

    var sourceViewController: UIViewController? { nil }

    func showMovieDetail(movieId: Int, from viewController: UIViewController) {
        Task { @MainActor in
            let destination = MovieDetailBuilder.build(
                movieId: movieId,
                dependencies: AppDependencies.shared,
                routing: self
            )
            viewController.navigationController?.hero.isEnabled = true
            viewController.navigationController?.hero.navigationAnimationType = .auto
            destination.hero.isEnabled = true
            viewController.navigationController?.pushViewController(destination, animated: true)
        }
    }

    func openURL(_ url: URL, from viewController: UIViewController) {
        Task { @MainActor in
            let safari = SFSafariViewController(url: url)
            viewController.present(safari, animated: true)
        }
    }

    func switchToHomeTab() {
        Task { @MainActor in
            tabBarController?.selectedIndex = 0
        }
    }

    func dismiss(from viewController: UIViewController) {
        viewController.navigationController?.popViewController(animated: true)
    }

    func showReviews(movieId: Int, movieTitle: String, from viewController: UIViewController) {
        let destination = ReviewsBuilder.build(movieId: movieId, dependencies: AppDependencies.shared)
        viewController.navigationController?.pushViewController(destination, animated: true)
    }
}
