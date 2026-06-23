import Foundation

public struct Genre: Codable, Equatable, Sendable {
    public let id: Int
    public let name: String

    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

public struct GenreListResponse: Codable, Sendable {
    public let genres: [Genre]
}

public struct Movie: Codable, Equatable, Sendable {
    public let id: Int
    public let title: String
    public let overview: String?
    public let posterPath: String?
    public let backdropPath: String?
    public let releaseDate: String?
    public let voteAverage: Double?

    enum CodingKeys: String, CodingKey {
        case id, title, overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
    }

    public init(
        id: Int,
        title: String,
        overview: String? = nil,
        posterPath: String? = nil,
        backdropPath: String? = nil,
        releaseDate: String? = nil,
        voteAverage: Double? = nil
    ) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.releaseDate = releaseDate
        self.voteAverage = voteAverage
    }

    public var releaseYear: String {
        guard let releaseDate, releaseDate.count >= 4 else { return "—" }
        return String(releaseDate.prefix(4))
    }
}

public struct PaginatedMoviesResponse: Codable, Sendable {
    public let page: Int
    public let totalPages: Int
    public let results: [Movie]

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
    }

    public init(page: Int, totalPages: Int, results: [Movie]) {
        self.page = page
        self.totalPages = totalPages
        self.results = results
    }
}

public struct MovieDetail: Codable, Sendable {
    public let id: Int
    public let title: String
    public let overview: String
    public let posterPath: String?
    public let backdropPath: String?
    public let runtime: Int?
    public let voteAverage: Double
    public let releaseDate: String?
    public let genres: [Genre]

    enum CodingKeys: String, CodingKey {
        case id, title, overview, runtime, genres
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
    }
}

public struct ReviewAuthorDetails: Codable, Sendable {
    public let name: String?
    public let username: String?
    public let avatarPath: String?

    enum CodingKeys: String, CodingKey {
        case name, username
        case avatarPath = "avatar_path"
    }
}

public struct Review: Codable, Sendable {
    public let author: String
    public let content: String
    public let createdAt: String
    public let authorDetails: ReviewAuthorDetails?
    public let rating: Double?

    enum CodingKeys: String, CodingKey {
        case author, content, rating
        case createdAt = "created_at"
        case authorDetails = "author_details"
    }

    public var displayContent: String {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "No review text available." : trimmed
    }
}

public struct PaginatedReviewsResponse: Codable, Sendable {
    public let page: Int
    public let totalPages: Int
    public let results: [Review]

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
    }
}

public struct Video: Codable, Sendable {
    public let key: String
    public let site: String
    public let type: String
}

public struct VideosResponse: Codable, Sendable {
    public let results: [Video]
}

public struct CastMember: Codable, Sendable {
    public let id: Int
    public let name: String
    public let character: String
    public let profilePath: String?

    enum CodingKeys: String, CodingKey {
        case id, name, character
        case profilePath = "profile_path"
    }
}

public struct CreditsResponse: Codable, Sendable {
    public let cast: [CastMember]
}

public struct MovieSnapshot: Codable, Equatable, Sendable {
    public let id: Int
    public let title: String
    public let posterPath: String?
    public let releaseYear: String
    public let rating: Double

    public init(id: Int, title: String, posterPath: String?, releaseYear: String, rating: Double) {
        self.id = id
        self.title = title
        self.posterPath = posterPath
        self.releaseYear = releaseYear
        self.rating = rating
    }

    public init(movie: Movie) {
        self.init(
            id: movie.id,
            title: movie.title,
            posterPath: movie.posterPath,
            releaseYear: movie.releaseYear,
            rating: movie.voteAverage ?? 0
        )
    }
}
