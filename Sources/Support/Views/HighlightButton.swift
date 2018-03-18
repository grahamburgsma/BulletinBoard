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

/**
* A view that wraps a HighlightButton.
*
* A wrapper is required to avoid alpha animation issues when unhighlighting the button and performing
* a bulletin transition.
*/

public class HighlightButtonWrapper: UIView {

	public let button: UIButton

	public override convenience init(frame: CGRect) {
		self.init(button: HighlightButton())
	}

	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) is unavailable. Use init(button:) instead.")
	}

	init(button: HighlightButton) {

		self.button = button
		super.init(frame: .zero)

		addSubview(button)
		button.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			button.leadingAnchor.constraint(equalTo: leadingAnchor),
			button.trailingAnchor.constraint(equalTo: trailingAnchor),
			button.topAnchor.constraint(equalTo: topAnchor),
			button.bottomAnchor.constraint(equalTo: bottomAnchor)
			])
	}
}
