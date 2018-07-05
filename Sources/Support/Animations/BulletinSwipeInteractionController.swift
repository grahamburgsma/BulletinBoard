/**
 *  BulletinBoard
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import UIKit

/**
 * An interaction controller that handles swipe-to-dismiss for bulletins.
 */

class BulletinSwipeInteractionController: UIPercentDrivenInteractiveTransition {

    private weak var transitionContext: UIViewControllerContextTransitioning?

    let panGestureRecognizer: UIPanGestureRecognizer

    lazy var longPressGestureRecognizer: UILongPressGestureRecognizer = {
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        recognizer.minimumPressDuration = 0.0
        recognizer.delegate = self
        return recognizer
    }()

    let animationController: BulletinAnimationController

    public init(animationController: BulletinAnimationController, panGestureRecognizer: UIPanGestureRecognizer) {
        self.panGestureRecognizer = panGestureRecognizer
        self.animationController = animationController

        super.init()

        panGestureRecognizer.delegate = self
        if panGestureRecognizer.state == .possible {
            wantsInteractiveStart = false
        }
    }

    deinit {
        longPressGestureRecognizer.view.map { $0.removeGestureRecognizer(longPressGestureRecognizer) }
        panGestureRecognizer.removeTarget(self, action: #selector(handleInteraction))
    }

    override open func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext

        animationController.setupAnimator(using: transitionContext)

        if panGestureRecognizer.state == .possible, !wantsInteractiveStart {
            animationController.animateTransition(using: transitionContext)
        }

        switch animationController.operation {
        case .present:
            transitionContext.view(forKey: .to)?.addGestureRecognizer(longPressGestureRecognizer)
        case .dismiss:
            transitionContext.view(forKey: .from)?.addGestureRecognizer(longPressGestureRecognizer)
        }

        panGestureRecognizer.addTarget(self, action: #selector(handleInteraction))
        panGestureRecognizer.setTranslation(.zero, in: transitionContext.containerView)

        super.startInteractiveTransition(transitionContext)
    }

    @objc private func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        let animator = animationController.animator!

        switch recognizer.state {
        case .began, .changed:
            if animator.isRunning {
                pause()
            }
        default:
            animator.startAnimation()
            update(animator.fractionComplete)
        }
    }

    @objc private func handleInteraction(_ recognizer: UIPanGestureRecognizer) {
        guard
            let context = transitionContext,
            let animator = animationController.animator
            else { return }

        switch recognizer.state {
        case .began:
            if animator.isRunning {
                pause()
            }

        case .changed:
            let translation = recognizer.translation(in: context.containerView)

            switch animationController.operation {
            case .present:
                animator.isReversed = true
            case .dismiss:
                animator.isReversed = false
            }

            let percentComplete = animator.fractionComplete + (translation.y / distance())

            animator.fractionComplete = min(percentComplete, 1.0)

            update(animator.fractionComplete)

            panGestureRecognizer.setTranslation(.zero, in: context.containerView)
        case .ended:
            interactionEnded()

        default: break
        }
    }

    private func distance() -> CGFloat {
        guard
            let context = transitionContext,
            let viewController = context.viewController(forKey: animationController.operation.contextViewControllerKey)
            else { return 0.0 }

        let frame: CGRect
        switch animationController.operation {
        case .present:
            frame = context.finalFrame(for: viewController)
        case .dismiss:
            frame = context.initialFrame(for: viewController)
        }

        return context.containerView.frame.height - frame.minY
    }

    private func interactionEnded() {
        guard
            let animator = animationController.animator,
            let context = transitionContext
            else { return }

        let operation = animationController.operation
        let fractionComplete = animator.fractionComplete
        let totalDuration = animator.duration

        let distance = self.distance()
        let velocity = panGestureRecognizer.velocity(in: context.containerView)
        let directionalVelocity = velocity.y
        let magnitude = abs(directionalVelocity)

        let shouldFinish = directionalVelocity > 0

        switch operation {
        case .present:

            if shouldFinish {
                completionSpeed = completionSpeedPositive(duration: totalDuration, velocity: magnitude, distance: distance)

                cancel()
            } else {
                completionSpeed = completionSpeedNegative(duration: totalDuration, velocity: magnitude, distance: distance, fractionComplete: fractionComplete)

                finish()
            }
        case .dismiss:

            if shouldFinish {
                completionSpeed = completionSpeedPositive(duration: totalDuration, velocity: magnitude, distance: distance)

                finish()
            } else {
                completionSpeed = completionSpeedNegative(duration: totalDuration, velocity: magnitude, distance: distance, fractionComplete: fractionComplete)

                cancel()
            }
        }
    }

    /**
     Multiplier to slow down all completions to give a more natual feel.
     Timing curve can distort time making the animation seem too fast.
     */
    private let completionSpeedMultiplier: CGFloat = 0.95

    /**
     Calculates the completion speed for the animation taking velocity and distance into consideration.

     ```1/x ((1 - fractionComplete) duration) = ((1 - fractionComplete) distance) / velocity```

     - x: The completion speed, we are solving for this.
     - ((1 - f) t): Is how completionSpeed is calculated by UIPercentDrivenInteractiveTransition.
     - ((1 - f) d) / v: Calculates the number of seconds the animation should take.

     - Note: (completionSpeed = x), (duration = t), (fractionComplete = f), (distance = d), (velocity = v)

     Simplifies to `x = (t v) / d`
     */
    private func completionSpeedPositive(duration: TimeInterval, velocity: CGFloat, distance: CGFloat) -> CGFloat {
        let speed = (CGFloat(duration) * velocity) / distance
        return speed * completionSpeedMultiplier
    }

    /**
     Similar to `completionSpeedPositive`, difference is (1 - f) on the RHS is now just (f).

     ```1/x ((1 - fractionComplete) duration) = (fractionComplete distance) / velocity```

     - Note: (completionSpeed = x), (duration = t), (fractionComplete = f), (distance = d), (velocity = v)

     Simplifies to `x = -(t (f - 1) v) / (f d)`
     */
    private func completionSpeedNegative(duration: TimeInterval, velocity: CGFloat, distance: CGFloat, fractionComplete: CGFloat) -> CGFloat {
        let speed = -((CGFloat(duration) * (fractionComplete - 1) * velocity) / (fractionComplete * distance))
        return speed * completionSpeedMultiplier
    }
}

extension BulletinSwipeInteractionController: UIGestureRecognizerDelegate {

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

    // MARK: - Math

//    // Source: https://github.com/HarshilShah/DeckTransition
//    let elasticTranslationCurve = { (translation: CGFloat, translationFactor: CGFloat) -> CGFloat in
//        return 30 * atan(translation/120) + translation/10
//    }
//
//    private func adaptativeTranslation(for translation: CGFloat, elasticThreshold: CGFloat) -> CGFloat {
//
//        let translationFactor: CGFloat = 2/3
//
//        if translation >= elasticThreshold {
//            let frictionLength = translation - elasticThreshold
//            let frictionTranslation = elasticTranslationCurve(frictionLength, translationFactor)
//            return frictionTranslation + (elasticThreshold * translationFactor)
//        } else {
//            return translation * translationFactor
//        }
//
//    }
//
//    private func transform(forTranslation translation: CGPoint) -> CGAffineTransform {
//
//        let translationFactor: CGFloat = 1/3
//        var adaptedTranslation = translation
//
//        // Vertical
//
//        if translation.y < 0 || !(isInteractionInProgress) {
//            adaptedTranslation.y = elasticTranslationCurve(translation.y, translationFactor)
//        }
//
//        let yTransform = adaptedTranslation.y * translationFactor
//
//        if viewController.traitCollection.horizontalSizeClass == .compact {
//            return CGAffineTransform(translationX: 0, y: yTransform)
//        }
//
//        // Horizontal
//
//        adaptedTranslation.x = elasticTranslationCurve(translation.x, translationFactor)
//        let xTransform = adaptedTranslation.x * translationFactor
//
//        return CGAffineTransform(translationX: xTransform, y: yTransform)
//
//    }
