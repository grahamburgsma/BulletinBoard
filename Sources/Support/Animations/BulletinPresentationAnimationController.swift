/**
 *  BulletinBoard
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import UIKit

/**
 * The animation controller for bulletin presentation.
 *
 * It moves the card on screen, creates and fades in the background view.
 */

class BulletinPresentationAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    let style: BulletinBackgroundViewStyle

    init(style: BulletinBackgroundViewStyle) {
        self.style = style
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let bulletinBoard = transitionContext.viewController(forKey: .to) as? BulletinBoard else {
            return
        }

		bulletinBoard.view.frame = transitionContext.finalFrame(for: bulletinBoard)
		transitionContext.containerView.addSubview(bulletinBoard.view)

		bulletinBoard.contentView.transform = CGAffineTransform(translationX: 0, y: bulletinBoard.view.frame.height)

        let duration = transitionDuration(using: transitionContext)
		UIView.animate(withDuration: duration, animations: {
			bulletinBoard.contentView.transform = CGAffineTransform.identity
		}) { _ in
			transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
		}
    }
}
