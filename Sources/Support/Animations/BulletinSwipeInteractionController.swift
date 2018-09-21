/**
 *  BulletinBoard
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import UIKit

/**
 * An interaction controller that handles swipe-to-dismiss for bulletins.
 */

final class BulletinSwipeInteractionController: UIPercentDrivenInteractiveTransition {

    private let primaryRubberConstant: CGFloat = 0.4
    private let secondaryRubberConstant: CGFloat = 0.1

    private let velocityTrigger: CGFloat = 2500
    private let offsetTrigger: CGFloat = 80

    var canDismiss: Bool = true

    private weak var transitionContext: UIViewControllerContextTransitioning?
    private let panGestureRecognizer: UIPanGestureRecognizer

    public init(panGestureRecognizer: UIPanGestureRecognizer) {
        self.panGestureRecognizer = panGestureRecognizer

        super.init()
    }

    deinit {
        panGestureRecognizer.removeTarget(self, action: #selector(handleInteraction))
    }

    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext

        panGestureRecognizer.addTarget(self, action: #selector(handleInteraction))
        panGestureRecognizer.setTranslation(.zero, in: transitionContext.containerView)

        super.startInteractiveTransition(transitionContext)

        if panGestureRecognizer.state == .possible || panGestureRecognizer.state == .failed {
            finish()
        }
    }

    @objc private func handleInteraction(_ recognizer: UIPanGestureRecognizer) {
        guard
            let context = transitionContext,
            let fromView = context.view(forKey: .from),
            let fromVC = context.viewController(forKey: .from)
            else { return }

        switch recognizer.state {
        case .changed:
            let translation = recognizer.translation(in: context.containerView)
            let constant: CGFloat = (translation.y > 0 && canDismiss) ? primaryRubberConstant : secondaryRubberConstant
            let dimension = context.containerView.frame.height - context.initialFrame(for: fromVC).minY
            let newTranslation = rubberBanded(translation: translation.y, constant: constant, dimension: dimension)
            fromView.transform.ty = newTranslation

            if context.containerView.traitCollection.horizontalSizeClass == .regular {
                let xTranslation = rubberBanded(translation: translation.x, constant: secondaryRubberConstant, dimension: dimension)
                fromView.transform.tx = xTranslation
            }

            if canDismiss, fromView.transform.ty > offsetTrigger {
                finish()
            }

        case .ended:
            if canDismiss, recognizer.velocity(in: context.containerView).y > velocityTrigger {
                finish()
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    fromView.transform = .identity
                }) { (_) in
                    fromView.transform = .identity
                }

                cancel()
            }
        default: break
        }
    }

    /// Rubber band effect equation
    /// - parameter translation: Distance from the edge.
    /// - parameter constant: Constant value. Default is 0.55 which matches UIScrollView
    /// - parameter dimension: Width or height of view for direction of scrolling.
    private func rubberBanded(translation: CGFloat, constant: CGFloat = 0.55, dimension: CGFloat) -> CGFloat {
        return (1.0 - (1.0 / ((translation * constant / dimension) + 1.0))) * dimension
    }
}
