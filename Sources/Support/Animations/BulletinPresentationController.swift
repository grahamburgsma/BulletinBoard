//
//  BulletinPresentationController.swift
//  BulletinBoard
//
//  Created by Graham Burgsma on 2018-01-12.
//  Copyright © 2018 Bulletin. All rights reserved.
//

import UIKit

class BulletinPresentationController: UIPresentationController {

    /// Dismiss the presented view controller when dimming view is tapped.
    /// Defaults to `true`.
    open var dimissOnTap: Bool = true

    /// Presented view should be placed within these insets.
    /// Defaults to (12, 12, 12, 12)
    open var contentMargins: UIEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

    private var keyboardHeight: CGFloat = 0

    let backgroundView: BulletinBackgroundView

	init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, backgroundStyle: BulletinBackgroundViewStyle) {
		backgroundView = BulletinBackgroundView(style: backgroundStyle)

		super.init(presentedViewController: presentedViewController, presenting: presentingViewController)

        if dimissOnTap {
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
            backgroundView.addGestureRecognizer(tapRecognizer)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
	}

    @objc func handleTapGesture() {
        presentedViewController.dismiss(animated: true)
    }

    open override var frameOfPresentedViewInContainerView: CGRect {
        var margins = contentMargins

        if keyboardHeight > 0 {
            margins.bottom += keyboardHeight
        } else if #available(iOS 11.0, *), let insets = containerView?.safeAreaInsets {
            margins += insets
        }

        let parentFrame = containerView!.bounds
        let availableSize = parentFrame.inset(by: margins).size
        let preferredSize = size(forChildContentContainer: presentedViewController,
                                 withParentContainerSize: availableSize)

        let width = min(preferredSize.width, availableSize.width)
        let height = min(preferredSize.height, availableSize.height)
        let newSize = CGSize(width: width, height: height)
        let origin: CGPoint

        if traitCollection.horizontalSizeClass == .regular {
            origin = CGPoint(x: (parentFrame.width - width) / 2,
                             y: (parentFrame.height - height) / 2)
        } else {
            origin = CGPoint(x: (parentFrame.width - width) / 2,
                             y: parentFrame.height - height - margins.bottom)
        }

        return CGRect(origin: origin, size: newSize)
    }

    open override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)

        if container === presentedViewController {
            containerView?.setNeedsLayout()
            containerView?.layoutIfNeeded()
        }
    }

    open override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return container.preferredContentSize
    }

    open override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }

    open override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()

        guard let containerView = containerView else { return }

        containerView.addSubview(backgroundView)
        backgroundView.frame = containerView.bounds
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        backgroundView.alpha = 0.0
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.backgroundView.alpha = 1.0
        })
    }

    open override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            backgroundView.removeFromSuperview()
        }
    }

    open override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.backgroundView.alpha = 0.0
        })
    }

    open override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            backgroundView.removeFromSuperview()
        }
    }

    // MARK: Keyboard avoidance

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrameFinal = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
            else { return }

        keyboardHeight = keyboardFrameFinal.height

        UIViewPropertyAnimator(duration: duration, curve: .easeOut) {
            self.containerView?.setNeedsLayout()
            self.containerView?.layoutIfNeeded()
        }.startAnimation()
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
            else { return }

        keyboardHeight = 0

        UIViewPropertyAnimator(duration: duration, curve: .easeOut) {
            self.containerView?.setNeedsLayout()
            self.containerView?.layoutIfNeeded()
            }.startAnimation()
    }
}
