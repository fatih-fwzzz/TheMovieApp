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

    private func configure() {
        titleLabel?.font = AppFont.labelLG()
        layer.cornerRadius = 18
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        updateAppearance()
    }

    private func updateAppearance() {
        if isChipSelected {
            backgroundColor = AppColor.primaryContainer
            setTitleColor(AppColor.highEmphasis, for: .normal)
        } else {
            backgroundColor = AppColor.surfaceContainerHigh
            setTitleColor(AppColor.onSurfaceVariant, for: .normal)
        }
    }
}

public final class AllFilterPillButton: UIButton {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setTitle("All", for: .normal)
        setTitleColor(AppColor.highEmphasis, for: .normal)
        titleLabel?.font = AppFont.labelLG()
        backgroundColor = AppColor.primaryContainer
        layer.cornerRadius = 18
        contentEdgeInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
    }

    required init?(coder: NSCoder) { fatalError() }
}
