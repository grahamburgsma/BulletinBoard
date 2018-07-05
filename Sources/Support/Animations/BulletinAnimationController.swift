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

class BulletinAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    let operation: TransitionOperation

    /// Duration for the total animation
    public var duration: TimeInterval = 0.4

    public var animator: UIViewPropertyAnimator!

    public init(operation: TransitionOperation) {
        self.operation = operation
    }

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        interruptibleAnimator(using: transitionContext).startAnimation()
    }

    public func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        if animator == nil {
            setupAnimator(using: transitionContext)
        }
        return animator
    }

    public func setupAnimator(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let viewController = transitionContext.viewController(forKey: operation.contextViewControllerKey),
            let view = transitionContext.view(forKey: operation.contextViewKey)
            else { return }

        let finalFrame = transitionContext.finalFrame(for: viewController)
        let duration = transitionDuration(using: transitionContext)
        let changes: () -> Void

        switch operation {
        case .present:
            transitionContext.containerView.addSubview(view)

            view.frame.origin.y = finalFrame.height

            changes = {
                view.frame = transitionContext.finalFrame(for: viewController)
            }
        case .dismiss:
            changes = {
                view.frame.origin.y = finalFrame.height
            }
        }

        animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1.0, animations: changes)

        animator.addCompletion { position in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
