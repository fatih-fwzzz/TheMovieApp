import Foundation

final class AppDependencies: FeatureDependencies {
    static let shared = AppDependencies()

    let movieService: MovieServiceProtocol
    let favoritesStore: FavoritesStoreProtocol
    let navigation = AppNavigation()

    private init() {
        let network = AlamofireNetworkService(bearerToken: AppConfiguration.tmdbBearerToken)
        movieService = TMDBMovieService(network: network)
        favoritesStore = FavoritesStore()
    }
}
