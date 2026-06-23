import UIKit
import HomeKit
import SearchKit
import FavoritesKit
import UIComponentKit

enum AppRootBuilder {
    static func buildRootViewController() -> UIViewController {
        let dependencies = AppDependencies.shared
        let navigation = AppNavigation()

        let homeNav = UINavigationController(
            rootViewController: HomeBuilder.build(dependencies: dependencies, routing: navigation)
        )
        homeNav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)

        let searchNav = UINavigationController(
            rootViewController: SearchBuilder.build(dependencies: dependencies, routing: navigation)
        )
        searchNav.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 1)

        let favoritesNav = UINavigationController(
            rootViewController: FavoritesBuilder.build(dependencies: dependencies, routing: navigation)
        )
        favoritesNav.tabBarItem = UITabBarItem(title: "Favorites", image: UIImage(systemName: "heart"), tag: 2)

        let tabBar = UITabBarController()
        tabBar.viewControllers = [homeNav, searchNav, favoritesNav]
        tabBar.view.backgroundColor = AppColor.background
        navigation.tabBarController = tabBar

        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        tabBar.tabBar.standardAppearance = appearance
        tabBar.tabBar.scrollEdgeAppearance = appearance
        tabBar.tabBar.tintColor = AppColor.primaryContainer
        tabBar.tabBar.unselectedItemTintColor = AppColor.onSurfaceVariant

        return tabBar
    }
}
