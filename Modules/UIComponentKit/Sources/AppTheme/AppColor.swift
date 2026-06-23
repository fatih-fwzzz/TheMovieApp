import UIKit

public enum AppColor {
    public static let background = UIColor(hex: 0x131313)
    public static let surface = UIColor(hex: 0x1E1E1E)
    public static let surfaceContainer = UIColor(hex: 0x201F1F)
    public static let surfaceContainerHigh = UIColor(hex: 0x2A2A2A)
    public static let primary = UIColor(hex: 0xFFB782)
    public static let primaryContainer = UIColor(hex: 0xFF8702)
    public static let onSurface = UIColor(hex: 0xE5E2E1)
    public static let onSurfaceVariant = UIColor(hex: 0xDEC1AE)
    public static let highEmphasis = UIColor.white
    public static let ratingGold = UIColor(hex: 0xFFC107)
    public static let outline = UIColor(hex: 0xA58C7B)
    public static let surfaceGlass = UIColor(white: 0.12, alpha: 0.7)
}

private extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        let r = CGFloat((hex >> 16) & 0xFF) / 255
        let g = CGFloat((hex >> 8) & 0xFF) / 255
        let b = CGFloat(hex & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
}
