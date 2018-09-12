/**
 *  BulletinBoard
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import UIKit

public enum BulletinBackgroundViewStyle {

	case none
	case dimmed
	case blurred(style: UIBlurEffect.Style)
}

/**
 * The view to display behind the bulletin.
 */

class BulletinBackgroundView: UIView {

    let style: BulletinBackgroundViewStyle

    // MARK: - Initialization

    init(style: BulletinBackgroundViewStyle) {
        self.style = style
        super.init(frame: .zero)
        initialize()
    }

    override init(frame: CGRect) {
        style = .dimmed
        super.init(frame: frame)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        style = .dimmed
        super.init(coder: aDecoder)
        initialize()
    }

    private func initialize() {


		switch style {
		case .none: break
		case .dimmed:
			alpha = 0
			backgroundColor = UIColor(white: 0.0, alpha: 0.5)
		case .blurred(let style):
			let blurEffect = UIBlurEffect(style: style)
			let blurEffectView = UIVisualEffectView(effect: blurEffect)
			blurEffectView.translatesAutoresizingMaskIntoConstraints = false
			addSubview(blurEffectView)

			NSLayoutConstraint.activate([
				blurEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
				blurEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
				blurEffectView.topAnchor.constraint(equalTo: topAnchor),
				blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor)
				])
		}
    }
}
