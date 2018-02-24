/**
 *  BulletinBoard
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import UIKit

/**
 * Generates interface elements for bulletins. Use this class to create custom bulletin items with
 * standard components.
 */

open class BulletinInterfaceBuilder {

    /**
     * Creates a standard title label.
     */

	static func titleLabel(text: String?) -> UILabel {

        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.textColor = #colorLiteral(red: 0.568627451, green: 0.5647058824, blue: 0.5725490196, alpha: 1)
        titleLabel.accessibilityTraits |= UIAccessibilityTraitHeader
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontSizeToFitWidth = true
		titleLabel.text = text

		titleLabel.font = .systemFont(ofSize: 30)

        return titleLabel
    }

    /**
     * Creates a standard description label.
     */

	static func descriptionLabel(text: String?) -> UILabel {

        let descriptionLabel = UILabel()
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = .black
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = .systemFont(ofSize: 20)
		descriptionLabel.text = text

        return descriptionLabel
    }

	static func imageView(image: UIImage) -> UIImageView {
		let imageView = UIImageView(image: image)
		imageView.contentMode = .scaleAspectFit
		imageView.heightAnchor.constraint(lessThanOrEqualToConstant: 128).isActive = true
		return imageView
	}

    /**
     * Creates a standard text field with an optional delegate.
     *
     * - parameter placeholder: The placeholder text.
     * - parameter returnKey: The type of return key to apply to the text field.
     * - parameter delegate: The delegate for the text field.
     */

    static func textField(placeholder: String? = nil,
                                  returnKey: UIReturnKeyType = .default,
                                  delegate: UITextFieldDelegate? = nil) -> UITextField {

        let textField = UITextField()
        textField.delegate = delegate
        textField.textAlignment = .left
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.returnKeyType = returnKey

        return textField
    }

    /**
     * Creates a standard action (main) button.
     *
     * The created button will have rounded corners, a background color set to the `tintColor` and
     * a title color set to `actionButtonTitleColor`.
     *
     * - parameter title: The title of the button.
     */

    static func actionButton(title: String?) -> HighlightButtonWrapper {

		let actionButton = HighlightButton(type: .custom)
		actionButton.setBackgroundColor(#colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), forState: .normal)
		actionButton.setTitleColor(.white, for: .normal)
		actionButton.contentHorizontalAlignment = .center

		actionButton.setTitle(title, for: .normal)
		actionButton.titleLabel?.font = .systemFont(ofSize: 17)

		actionButton.layer.cornerRadius = 12
		actionButton.clipsToBounds = true

		actionButton.heightAnchor.constraint(equalToConstant: 55).isActive = true

        return HighlightButtonWrapper(button: actionButton)
    }

    /**
     * Creates a standard alternative button.
     *
     * The created button will have no background color and a title color set to `tintColor`.
     *
     * - parameter title: The title of the button.
     */

    static func alternativeButton(title: String?) -> UIButton {

        let alternativeButton = UIButton(type: .system)
        alternativeButton.setTitle(title, for: .normal)
        alternativeButton.setTitleColor(#colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), for: .normal)
        alternativeButton.titleLabel?.font = .systemFont(ofSize: 15)

        return alternativeButton
    }
}
