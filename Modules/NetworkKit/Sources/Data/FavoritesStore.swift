import Foundation

public protocol FavoritesStoreProtocol: AnyObject {
    func allFavorites() -> [MovieSnapshot]
    func add(_ movie: MovieSnapshot)
    func remove(movieId: Int)
    func isFavorite(movieId: Int) -> Bool
}

public final class FavoritesStore: FavoritesStoreProtocol {
    private let defaults: UserDefaults
    private let storageKey = "themovie.favorites"

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func allFavorites() -> [MovieSnapshot] {
        guard let data = defaults.data(forKey: storageKey) else { return [] }
        return (try? JSONDecoder().decode([MovieSnapshot].self, from: data)) ?? []
    }

    public func add(_ movie: MovieSnapshot) {
        var items = allFavorites()
        guard !items.contains(where: { $0.id == movie.id }) else { return }
        items.insert(movie, at: 0)
        save(items)
    }

    public func remove(movieId: Int) {
        var items = allFavorites()
        items.removeAll { $0.id == movieId }
        save(items)
    }

    public func isFavorite(movieId: Int) -> Bool {
        allFavorites().contains { $0.id == movieId }
    }

    private func save(_ items: [MovieSnapshot]) {
        guard let data = try? JSONEncoder().encode(items) else { return }
        defaults.set(data, forKey: storageKey)
    }
}
