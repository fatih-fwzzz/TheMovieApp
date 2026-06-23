import Foundation

public protocol NetworkServiceProtocol: Sendable {
    func request<T: Decodable>(_ type: T.Type, endpoint: TMDBEndpoint) async throws -> T
}

public final class AlamofireNetworkService: NetworkServiceProtocol, @unchecked Sendable {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func request<T: Decodable>(_ type: T.Type, endpoint: TMDBEndpoint) async throws -> T {
        guard let url = endpoint.url else { throw NetworkError.invalidURL }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(AppConfiguration.tmdbBearerToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw NetworkError.unknown }
            switch http.statusCode {
            case 200...299:
                break
            case 401:
                throw NetworkError.serverError(statusCode: 401)
            default:
                throw NetworkError.serverError(statusCode: http.statusCode)
            }
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingFailed
            }
        } catch let error as NetworkError {
            throw error
        } catch let error as URLError where error.code == .notConnectedToInternet {
            throw NetworkError.noInternetConnection
        } catch {
            throw NetworkError.unknown
        }
    }
}
