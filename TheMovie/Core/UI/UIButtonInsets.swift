import UIKit

enum UIButtonInsets {
    static func apply(_ insets: UIEdgeInsets, to button: UIButton) {
        var config = button.configuration ?? .plain()
        config.contentInsets = NSDirectionalEdgeInsets(
            top: insets.top,
            leading: insets.left,
            bottom: insets.bottom,
            trailing: insets.right
        )
        button.configuration = config
    }

    static func applyTitleFont(_ font: UIFont, to button: UIButton) {
        var config = button.configuration ?? .plain()
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = font
            return outgoing
        }
        button.configuration = config
    }
}
