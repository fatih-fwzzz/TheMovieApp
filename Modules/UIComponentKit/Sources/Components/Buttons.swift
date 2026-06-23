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

    private func configure() {
        backgroundColor = AppColor.primaryContainer
        setTitleColor(AppColor.highEmphasis, for: .normal)
        titleLabel?.font = AppFont.labelLG()
        layer.cornerRadius = 26
        layer.shadowColor = AppColor.primaryContainer.cgColor
        layer.shadowOpacity = 0.35
        layer.shadowRadius = 12
        layer.shadowOffset = CGSize(width: 0, height: 4)
        contentEdgeInsets = UIEdgeInsets(top: 14, left: 24, bottom: 14, right: 24)
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

    private func configure() {
        backgroundColor = AppColor.surfaceContainer
        setTitleColor(AppColor.onSurface, for: .normal)
        titleLabel?.font = AppFont.labelLG()
        layer.cornerRadius = AppRadius.roundedLG
        layer.borderWidth = 1
        layer.borderColor = AppColor.outline.cgColor
        contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
    }
}
