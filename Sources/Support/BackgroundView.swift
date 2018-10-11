/**
 *  BulletinBoard
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import UIKit

/**
 * The view to display behind the bulletin board.
 */

public class BackgroundView: UIView {

    public enum Style {
        case none
        case dimmed
        case blurred(style: UIBlurEffect.Style)
    }

    let style: Style

    // MARK: - Initialization

    init(style: Style) {
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
		case .none:
            break

		case .dimmed:
			alpha = 0
			backgroundColor = UIColor(white: 0.0, alpha: 0.5)

        case .blurred(let style):
			let blurEffect = UIBlurEffect(style: style)
			let blurEffectView = UIVisualEffectView(effect: blurEffect)

            blurEffectView.frame = bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addSubview(blurEffectView)
		}
    }
}
