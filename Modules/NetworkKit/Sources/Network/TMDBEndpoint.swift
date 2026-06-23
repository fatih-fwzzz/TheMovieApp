import Foundation

public enum TMDBEndpoint {
    case genreList
    case discoverMovies(genreId: Int?, page: Int)
    case trendingWeek
    case searchMovies(query: String, page: Int)
    case movieDetail(id: Int)
    case movieReviews(id: Int, page: Int)
    case movieVideos(id: Int)
    case movieCredits(id: Int)

    private static let baseURL = "https://api.themoviedb.org/3"

    public var path: String {
        switch self {
        case .genreList:
            return "/genre/movie/list"
        case .discoverMovies:
            return "/discover/movie"
        case .trendingWeek:
            return "/trending/movie/week"
        case .searchMovies:
            return "/search/movie"
        case .movieDetail(let id):
            return "/movie/\(id)"
        case .movieReviews(let id, _):
            return "/movie/\(id)/reviews"
        case .movieVideos(let id):
            return "/movie/\(id)/videos"
        case .movieCredits(let id):
            return "/movie/\(id)/credits"
        }
    }

    public var queryItems: [URLQueryItem] {
        switch self {
        case .genreList:
            return [URLQueryItem(name: "language", value: "en-US")]
        case .discoverMovies(let genreId, let page):
            var items = [
                URLQueryItem(name: "language", value: "en-US"),
                URLQueryItem(name: "sort_by", value: "popularity.desc"),
                URLQueryItem(name: "page", value: "\(page)")
            ]
            if let genreId {
                items.append(URLQueryItem(name: "with_genres", value: "\(genreId)"))
            }
            return items
        case .trendingWeek:
            return [URLQueryItem(name: "language", value: "en-US")]
        case .searchMovies(let query, let page):
            return [
                URLQueryItem(name: "language", value: "en-US"),
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "page", value: "\(page)")
            ]
        case .movieDetail, .movieCredits, .movieVideos:
            return [URLQueryItem(name: "language", value: "en-US")]
        case .movieReviews(_, let page):
            return [
                URLQueryItem(name: "language", value: "en-US"),
                URLQueryItem(name: "page", value: "\(page)")
            ]
        }
    }

    public var url: URL? {
        guard var components = URLComponents(string: Self.baseURL + path) else { return nil }
        components.queryItems = queryItems
        return components.url
    }
}
