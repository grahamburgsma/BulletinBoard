//
//  BulletinBoard+Keyboard.swift
//  BulletinBoard
//
//  Created by Graham Burgsma on 2018-01-12.
//  Copyright © 2018 Bulletin. All rights reserved.
//

import UIKit

extension BulletinBoard {

	private var spacing: CGFloat { return 12 }

	func setUpKeyboardLogic() {
		NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
	}

	@objc func onKeyboardShow(_ notification: Notification) {

		guard currentItem.shouldRespondToKeyboardChanges == true else {
			return
		}

		guard let userInfo = notification.userInfo,
			let keyboardFrameFinal = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
			let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
			let curveInt = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int
			else {
				return
		}

		let animationOptions = UIView.AnimationOptions(rawValue: UInt(curveInt << 16))

//        if centerYConstraint.isActive { // iPad
//            let offset = keyboardFrameFinal.minY - contentView.frame.maxY - spacing
//            if offset < 0 {
//                centerYConstraint.constant = offset
//            }
//        } else if bottomYConstraint.isActive { //iPhone
//            bottomYConstraint.constant = keyboardFrameFinal.height
//        }

		UIView.animate(withDuration: duration, delay: 0, options: animationOptions, animations: {
			self.view.layoutIfNeeded()
		}, completion: nil)
	}

	@objc func onKeyboardHide(_ notification: Notification) {

		guard currentItem.shouldRespondToKeyboardChanges == true else {
			return
		}

		guard let userInfo = notification.userInfo,
			let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
			let curveInt = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int
			else {
				return
		}

		let animationOptions = UIView.AnimationOptions(rawValue: UInt(curveInt << 16))

//        centerYConstraint.constant = 0
//        bottomYConstraint.constant = spacing

		UIView.animate(withDuration: duration, delay: 0, options: animationOptions, animations: {
			self.view.layoutIfNeeded()
		}, completion: nil)
	}
}
