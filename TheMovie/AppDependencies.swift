import Foundation
import NetworkKit

final class AppDependencies: FeatureDependencies {
    static let shared = AppDependencies()

    let movieService: MovieServiceProtocol
    let favoritesStore: FavoritesStoreProtocol
    let navigation = AppNavigation()

    private init() {
        let network = AlamofireNetworkService()
        movieService = TMDBMovieService(network: network)
        favoritesStore = FavoritesStore()
    }
}
