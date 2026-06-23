import UIKit

public final class SearchBarView: UIView {
    public let textField = UITextField()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = AppColor.surfaceContainer
        layer.cornerRadius = 22

        let icon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        icon.tintColor = AppColor.onSurfaceVariant
        icon.translatesAutoresizingMaskIntoConstraints = false

        textField.font = AppFont.bodyMD()
        textField.textColor = AppColor.onSurface
        textField.tintColor = AppColor.primaryContainer
        textField.translatesAutoresizingMaskIntoConstraints = false

        addSubview(icon)
        addSubview(textField)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 44),
            icon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            icon.centerYAnchor.constraint(equalTo: centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 18),
            icon.heightAnchor.constraint(equalToConstant: 18),
            textField.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            textField.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    public func setPlaceholder(_ text: String) {
        textField.attributedPlaceholder = NSAttributedString(
            string: text,
            attributes: [.foregroundColor: AppColor.onSurfaceVariant]
        )
    }
}
