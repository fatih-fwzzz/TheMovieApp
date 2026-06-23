import UIKit

private enum LiquidGlassTag {
    static let effectView = 99_901
}

public enum LiquidGlassStyle {
    public static func apply(
        to button: UIButton,
        cornerRadius: CGFloat,
        tintColor: UIColor? = nil,
        isInteractive: Bool = true
    ) {
        button.backgroundColor = .clear
        button.subviews.filter { $0.tag == LiquidGlassTag.effectView }.forEach { $0.removeFromSuperview() }

        let glassEffect = UIGlassEffect()
        glassEffect.isInteractive = isInteractive
        glassEffect.tintColor = tintColor

        let effectView = UIVisualEffectView(effect: glassEffect)
        effectView.tag = LiquidGlassTag.effectView
        effectView.isUserInteractionEnabled = false
        effectView.layer.cornerRadius = cornerRadius
        effectView.clipsToBounds = true
        effectView.frame = button.bounds
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        button.insertSubview(effectView, at: 0)
    }

    public static func refreshLayout(for button: UIButton, cornerRadius: CGFloat) {
        guard let effectView = button.viewWithTag(LiquidGlassTag.effectView) as? UIVisualEffectView else { return }
        effectView.frame = button.bounds
        effectView.layer.cornerRadius = cornerRadius
    }
}
