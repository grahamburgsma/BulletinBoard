/**
 *  BulletinBoard
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import UIKit

/**
 * A standard bulletin item with a title and optional additional informations. It can display a large
 * action button and a smaller button for alternative options.
 */

open class PageBulletinItem: BulletinItem {

	public weak var board: BulletinBoard?

	open var isDismissable: Bool = false

	open var shouldRespondToKeyboardChanges: Bool = true

	public var dismissalHandler: ((BulletinItem) -> Void)?

	public var views: [UIView] = [UIView]()

	public private(set) var titleLabel: UILabel?
	public private(set) var imageView: UIImageView?
	public private(set) var descriptionLabel: UILabel?

	public private(set) var mainButton: UIButton?
	public private(set) var alternateButton: UIButton?

	public private(set) var mainAction: BulletinItemAction?
	public private(set) var alternateAction: BulletinItemAction?

	public init(title: String?, image: UIImage? = nil, description: String?, mainAction: BulletinItemAction?, alternateAction: BulletinItemAction? = nil) {
		if let title = title {
			let label = BulletinInterfaceBuilder.titleLabel(text: title)
			titleLabel = label
			views.append(label)
		}

		if let image = image {
			let imageView = BulletinInterfaceBuilder.imageView(image: image)
			self.imageView = imageView
			views.append(imageView)
		}

		if let description = description {
			let label = BulletinInterfaceBuilder.descriptionLabel(text: description)
			descriptionLabel = label
			views.append(label)
		}

		var buttons = [UIView]()

		if let action = mainAction {
			let button = BulletinInterfaceBuilder.actionButton(title: action.title)
			mainButton = button
			self.mainAction = action
			button.addTarget(self, action: #selector(buttonTouchUpInside(_:)), for: .touchUpInside)
			buttons.append(button)
		}

		if let action = alternateAction {
			let button = BulletinInterfaceBuilder.alternativeButton(title: action.title)
			alternateButton = button
			self.alternateAction = action
			button.addTarget(self, action: #selector(buttonTouchUpInside(_:)), for: .touchUpInside)
			buttons.append(button)
		}

		if buttons.isEmpty == false {
			let buttonStackView = UIStackView(arrangedSubviews: buttons)
			buttonStackView.axis = .vertical
			buttonStackView.spacing = 10
			views.append(buttonStackView)
		}
    }

	@objc open func buttonTouchUpInside(_ sender: UIButton) {
		if sender == mainButton {
			mainAction?.handler?(self)
		} else if sender == alternateButton {
			alternateAction?.handler?(self)
		}
	}
}
