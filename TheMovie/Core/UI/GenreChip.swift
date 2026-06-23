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
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = AppFont.labelLG()
            return outgoing
        }
        configuration = config
        layer.cornerRadius = 18
        updateAppearance()
    }

    private func updateAppearance() {
        var config = configuration ?? .plain()
        if isChipSelected {
            config.baseForegroundColor = AppColor.highEmphasis
            LiquidGlassStyle.apply(to: self, cornerRadius: 18, tintColor: AppColor.primaryContainer)
        } else {
            config.baseForegroundColor = AppColor.onSurfaceVariant
            LiquidGlassStyle.apply(to: self, cornerRadius: 18, tintColor: AppColor.surfaceContainerHigh)
        }
        configuration = config
    }
}
