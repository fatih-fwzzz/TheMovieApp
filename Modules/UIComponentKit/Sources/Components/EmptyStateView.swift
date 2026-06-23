import UIKit

public final class EmptyStateView: UIView {
    private let messageLabel = UILabel()
    public let actionButton = UIButton(type: .system)

    public override init(frame: CGRect) {
        super.init(frame: frame)
        let stack = UIStackView(arrangedSubviews: [messageLabel, actionButton])
        stack.axis = .vertical
        stack.spacing = AppSpacing.stackLG
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        messageLabel.font = AppFont.bodyLG()
        messageLabel.textColor = AppColor.onSurfaceVariant
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        actionButton.setTitleColor(AppColor.onSurfaceVariant, for: .normal)
        actionButton.titleLabel?.font = AppFont.labelLG()
        actionButton.backgroundColor = AppColor.surface
        actionButton.layer.cornerRadius = AppRadius.rounded
        actionButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -20)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    public func configure(message: String, actionTitle: String?) {
        messageLabel.text = message
        actionButton.setTitle(actionTitle, for: .normal)
        actionButton.isHidden = actionTitle == nil
    }
}
