import UIKit

/**
 * The animation controller for bulletin dismissal.
 *
 * It moves the card out of the screen, fades out the background view and removes it from the hierarchy
 * on completion.
 */

class BulletinDismissalAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		guard let bulletinBoard = transitionContext.viewController(forKey: .from) as? BulletinBoard else {
			transitionContext.completeTransition(false)
			return
		}

        let duration = transitionDuration(using: transitionContext)
		UIView.animate(withDuration: duration, animations: {
			bulletinBoard.contentView.transform = CGAffineTransform(translationX: 0, y: bulletinBoard.view.frame.height)
		}) { _ in
			transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
		}
    }
}
