/**
 *  BulletinBoard
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import UIKit

/**
 * A standard bulletin item with a title and optional additional informations. It can display a large
 * action button and a smaller button for alternative options.
 *
* - If you need to display custom elements with the standard butvars, subclass `PageBulletinItem` and
 * implement the `makeArrangedSubviews` method to return the elements to display above the buttons.
 *
 * You can also override this class to customize button tap handling. Override the `actionButtonTapped(sender:)`
 * and `alternativeButtonTapped(sender:)` methods to handle tap events. Make sure to call `super` in your
 * implementations if you do.
 *
 * Use the `appearance` property to customize the appearance of the page. If you want to use a different interface
 * builder type, change the `InterfaceBuilderType` property.
 */

open class PageBulletinItem: NSObject, BulletinItem {

	public weak var board: BulletinBoard?

	public var isDismissable: Bool = false

	public var shouldRespondToKeyboardChanges: Bool = true

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
		super.init()

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

	deinit {
		print(String(describing: self))
	}
}
