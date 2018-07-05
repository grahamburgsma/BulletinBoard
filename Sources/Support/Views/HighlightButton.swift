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
			UIView.transition(with: self, duration: 0.1, animations: {
				self.alpha = self.isHighlighted ? 0.5 : 1.0
			})
		}
	}
}
