import Foundation

public protocol FeatureDependencies: AnyObject {
    var movieService: MovieServiceProtocol { get }
    var favoritesStore: FavoritesStoreProtocol { get }
}

public protocol PaginatableInteractorProtocol: AnyObject {
    var currentPage: Int { get }
    var isFetching: Bool { get }
    var hasReachedEnd: Bool { get }
}
