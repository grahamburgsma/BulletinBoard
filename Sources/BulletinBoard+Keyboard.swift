//
//  BulletinBoard+Keyboard.swift
//  BulletinBoard
//
//  Created by Graham Burgsma on 2018-01-12.
//  Copyright © 2018 Bulletin. All rights reserved.
//

import UIKit

extension BulletinBoard {

	func setUpKeyboardLogic() {
		NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardShow), name: .UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardHide), name: .UIKeyboardWillHide, object: nil)
	}

	func cleanUpKeyboardLogic() {
		NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
		NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
	}

	@objc func onKeyboardShow(_ notification: Notification) {

		guard currentItem.shouldRespondToKeyboardChanges == true else {
			return
		}

		guard let userInfo = notification.userInfo,
			let keyboardFrameFinal = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect,
			let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double,
			let curveInt = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? Int
			else {
				return
		}

		let animationCurve = UIViewAnimationCurve(rawValue: curveInt) ?? .linear
		let animationOptions = UIViewAnimationOptions(curve: animationCurve)

		UIView.animate(withDuration: duration, delay: 0, options: animationOptions, animations: {
			var bottomSpacing = -(keyboardFrameFinal.size.height + self.bottomMargin())

			if #available(iOS 11.0, *) {

				if self.hidesHomeIndicator == false {
					bottomSpacing += self.view.safeAreaInsets.bottom
				}

			}

//			self.minYConstraint.isActive = false
//			self.contentBottomConstraint.constant = bottomSpacing
//			self.centerYConstraint.constant = -(keyboardFrameFinal.size.height + 12) / 2
//			self.contentView.superview?.layoutIfNeeded()

		}, completion: nil)

	}

	@objc func onKeyboardHide(_ notification: Notification) {

		guard currentItem.shouldRespondToKeyboardChanges == true else {
			return
		}

		guard let userInfo = notification.userInfo,
			let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double,
			let curveInt = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? Int
			else {
				return
		}

		let animationCurve = UIViewAnimationCurve(rawValue: curveInt) ?? .linear
		let animationOptions = UIViewAnimationOptions(curve: animationCurve)

		UIView.animate(withDuration: duration, delay: 0, options: animationOptions, animations: {
//			self.minYConstraint.isActive = true
//			self.contentBottomConstraint.constant = -self.bottomMargin()
//			self.centerYConstraint.constant = 0
//			self.contentView.superview?.layoutIfNeeded()
		}, completion: nil)

	}
}
