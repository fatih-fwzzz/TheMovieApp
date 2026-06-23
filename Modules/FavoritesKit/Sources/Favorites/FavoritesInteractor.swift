import Foundation
import NetworkKit

public final class FavoritesInteractor: FavoritesInteracting {
    private let store: FavoritesStoreProtocol

    public init(store: FavoritesStoreProtocol) {
        self.store = store
    }

    public func fetchFavorites() -> [MovieSnapshot] {
        store.allFavorites()
    }

    public func removeFavorite(movieId: Int) {
        store.remove(movieId: movieId)
    }
}
