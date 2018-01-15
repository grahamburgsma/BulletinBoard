/**
*  BulletinBoard
*  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
*/

import UIKit

/**
* A button that provides a visual feedback when the user interacts with it.
*
* This style of button works best with a solid background color. Use the `setBackgroundColor`
* function on `UIButton` to set one.
*/

public class HighlightButton: UIButton {

	public override init(frame: CGRect) {
		super.init(frame: frame)

		configure()
	}

	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

		configure()
	}

	func configure() {
		adjustsImageWhenHighlighted = false
	}

	override public var isHighlighted: Bool {
		didSet {
			adjustsImageWhenHighlighted = false
			UIView.transition(with: self, duration: 0.1, animations: {
				self.alpha = self.isHighlighted ? 0.5 : 1.0
			})
		}
	}
}

extension UIButton {

	/**
	* Sets a solid background color for the button.
	*/

	public func setBackgroundColor(_ color: UIColor, forState controlState: UIControlState) {
		UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
		UIGraphicsGetCurrentContext()?.setFillColor(color.cgColor)
		UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
		let colorImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		setBackgroundImage(colorImage, for: controlState)
	}
}
