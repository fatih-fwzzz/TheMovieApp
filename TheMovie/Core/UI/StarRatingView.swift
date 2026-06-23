import UIKit

public final class StarRatingView: UIStackView {
    private let starImageView = UIImageView(image: UIImage(systemName: "star.fill"))
    private let scoreLabel = UILabel()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        axis = .horizontal
        spacing = 4
        alignment = .center
        starImageView.tintColor = AppColor.ratingGold
        starImageView.contentMode = .scaleAspectFit
        starImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            starImageView.widthAnchor.constraint(equalToConstant: 14),
            starImageView.heightAnchor.constraint(equalToConstant: 14)
        ])
        scoreLabel.font = AppFont.labelSM()
        scoreLabel.textColor = AppColor.onSurfaceVariant
        addArrangedSubview(starImageView)
        addArrangedSubview(scoreLabel)
    }

    required init(coder: NSCoder) { fatalError() }

    public func configure(score: String, goldScore: Bool = false) {
        scoreLabel.text = score
        scoreLabel.textColor = goldScore ? AppColor.ratingGold : AppColor.onSurfaceVariant
    }
}
