import UIKit

public final class PrimaryButton: UIButton {
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
        LiquidGlassStyle.refreshLayout(for: self, cornerRadius: 26)
    }

    private func configure() {
        setTitleColor(AppColor.highEmphasis, for: .normal)
        titleLabel?.font = AppFont.labelLG()
        layer.cornerRadius = 26
        contentEdgeInsets = UIEdgeInsets(top: 14, left: 24, bottom: 14, right: 24)
        LiquidGlassStyle.apply(to: self, cornerRadius: 26, tintColor: AppColor.primaryContainer)
    }
}

public final class OutlinedButton: UIButton {
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
        LiquidGlassStyle.refreshLayout(for: self, cornerRadius: AppRadius.roundedLG)
    }

    private func configure() {
        setTitleColor(AppColor.onSurface, for: .normal)
        titleLabel?.font = AppFont.labelLG()
        layer.cornerRadius = AppRadius.roundedLG
        contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        LiquidGlassStyle.apply(to: self, cornerRadius: AppRadius.roundedLG, tintColor: AppColor.surfaceContainer)
    }
}
