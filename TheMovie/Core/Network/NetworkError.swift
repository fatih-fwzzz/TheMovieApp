import Foundation

public enum NetworkError: Error, LocalizedError, Equatable {
    case invalidURL
    case noInternetConnection
    case serverError(statusCode: Int)
    case decodingFailed
    case unknown

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL was malformed."
        case .noInternetConnection:
            return "No internet connection. Please try again."
        case .serverError(let code):
            return "Server returned an error (HTTP \(code))."
        case .decodingFailed:
            return "Failed to parse the server response."
        case .unknown:
            return "An unexpected error occurred."
        }
    }
}
