import UIKit
import SkeletonView

public enum SkeletonHelper {
    public static func apply(to view: UIView) {
        view.isSkeletonable = true
        view.showAnimatedGradientSkeleton(
            usingGradient: .init(baseColor: AppColor.surface, secondaryColor: AppColor.surfaceContainerHigh)
        )
    }

    public static func hide(from view: UIView) {
        view.hideSkeleton()
    }
}
