//
//  BulletinPresentationController.swift
//  BulletinBoard
//
//  Created by Graham Burgsma on 2018-01-12.
//  Copyright © 2018 Bulletin. All rights reserved.
//

import UIKit

class BulletinPresentationController: UIPresentationController {

	let backgroundView: BulletinBackgroundView

	init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, backgroundStyle: BulletinBackgroundViewStyle) {
		backgroundView = BulletinBackgroundView(style: backgroundStyle)

		super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
	}

	override func presentationTransitionWillBegin() {
		guard let containerView = containerView else { return }

		backgroundView.frame = containerView.bounds
		backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		containerView.addSubview(backgroundView)

		self.backgroundView.alpha = 0
		presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
			self.backgroundView.alpha = 1
		}, completion: nil)
	}

	override func presentationTransitionDidEnd(_ completed: Bool) {
		if !completed {
			backgroundView.removeFromSuperview()
		}
	}

	override func dismissalTransitionWillBegin() {
		presentingViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
			self.backgroundView.alpha = 0
		}, completion: nil)
	}

	override func dismissalTransitionDidEnd(_ completed: Bool) {
		if completed {
			backgroundView.removeFromSuperview()
		}
	}
}
