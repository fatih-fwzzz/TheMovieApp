import UIKit

public enum AppFont {
    public static func headlineXL() -> UIFont { .systemFont(ofSize: 32, weight: .bold) }
    public static func headlineLG() -> UIFont { .systemFont(ofSize: 24, weight: .bold) }
    public static func headlineMD() -> UIFont { .systemFont(ofSize: 20, weight: .semibold) }
    public static func bodyLG() -> UIFont { .systemFont(ofSize: 16, weight: .regular) }
    public static func bodyMD() -> UIFont { .systemFont(ofSize: 14, weight: .regular) }
    public static func labelLG() -> UIFont { .systemFont(ofSize: 14, weight: .semibold) }
    public static func labelSM() -> UIFont { .systemFont(ofSize: 12, weight: .medium) }
}

public enum AppSpacing {
    public static let base: CGFloat = 8
    public static let gutter: CGFloat = 16
    public static let containerMargin: CGFloat = 20
    public static let stackSM: CGFloat = 4
    public static let stackMD: CGFloat = 12
    public static let stackLG: CGFloat = 24
    public static let sectionGap: CGFloat = 32
}

public enum AppRadius {
    public static let roundedSM: CGFloat = 4
    public static let rounded: CGFloat = 8
    public static let roundedMD: CGFloat = 12
    public static let roundedLG: CGFloat = 16
    public static let roundedXL: CGFloat = 24
    public static let roundedFull: CGFloat = 9999
}
