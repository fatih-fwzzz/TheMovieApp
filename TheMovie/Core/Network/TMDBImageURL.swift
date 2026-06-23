import Foundation

public enum TMDBImageURL {
  public static let base = "https://image.tmdb.org/t/p"

  public static func poster(path: String?, size: String = "w500") -> URL? {
    guard let path, !path.isEmpty else { return nil }
    return URL(string: "\(base)/\(size)\(path)")
  }

  public static func backdrop(path: String?, size: String = "w780") -> URL? {
    guard let path, !path.isEmpty else { return nil }
    return URL(string: "\(base)/\(size)\(path)")
  }

  public static func profile(path: String?, size: String = "w185") -> URL? {
    guard let path, !path.isEmpty else { return nil }
    return URL(string: "\(base)/\(size)\(path)")
  }
}
