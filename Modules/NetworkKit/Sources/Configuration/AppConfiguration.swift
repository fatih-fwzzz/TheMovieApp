import Foundation

public enum AppConfiguration {
    public static var tmdbBearerToken: String {
        if let token = Bundle.main.infoDictionary?["TMDBBearerToken"] as? String,
           isValidToken(token) {
            return token
        }
        if let envToken = ProcessInfo.processInfo.environment["TMDB_BEARER_TOKEN"],
           isValidToken(envToken) {
            return envToken
        }
        #if DEBUG
        return ""
        #else
        fatalError("TMDB Bearer Token not found. Check your .env and Config.xcconfig setup.")
        #endif
    }

    private static func isValidToken(_ token: String) -> Bool {
        !token.isEmpty
            && token != "your_tmdb_read_access_token_here"
            && !token.contains("$(TMDB_BEARER_TOKEN)")
    }
}
