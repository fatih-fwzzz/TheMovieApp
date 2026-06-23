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
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = AppColor.highEmphasis
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 24, bottom: 14, trailing: 24)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = AppFont.labelLG()
            return outgoing
        }
        configuration = config
        layer.cornerRadius = 26
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
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = AppColor.onSurface
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = AppFont.labelLG()
            return outgoing
        }
        configuration = config
        layer.cornerRadius = AppRadius.roundedLG
        LiquidGlassStyle.apply(to: self, cornerRadius: AppRadius.roundedLG, tintColor: AppColor.surfaceContainer)
    }
}
