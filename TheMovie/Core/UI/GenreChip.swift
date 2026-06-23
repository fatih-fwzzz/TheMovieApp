import UIKit

public final class GenreChipButton: UIButton {
    public var isChipSelected = false {
        didSet { updateAppearance() }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        LiquidGlassStyle.refreshLayout(for: self, cornerRadius: 18)
    }

    private func configure() {
        titleLabel?.font = AppFont.labelLG()
        layer.cornerRadius = 18
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        updateAppearance()
    }

    private func updateAppearance() {
        if isChipSelected {
            setTitleColor(AppColor.highEmphasis, for: .normal)
            LiquidGlassStyle.apply(to: self, cornerRadius: 18, tintColor: AppColor.primaryContainer)
        } else {
            setTitleColor(AppColor.onSurfaceVariant, for: .normal)
            LiquidGlassStyle.apply(to: self, cornerRadius: 18, tintColor: AppColor.surfaceContainerHigh)
        }
    }
}
