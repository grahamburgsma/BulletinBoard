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
	public private(set) var descriptionLabel: UILabel?
	public private(set) var imageView: UIImageView?

	private var actions = [UIButton: BulletinItemAction]()

	public init(title: String?, description: String?, image: UIImage?) {
		if let title = title {
			views.append(BulletinInterfaceBuilder.titleLabel(text: title))
		}
		if let description = description {
			views.append(BulletinInterfaceBuilder.descriptionLabel(text: description))
		}
		if let image = image {
			views.append(BulletinInterfaceBuilder.imageView(image: image))
		}
    }

	public func addAction(_ action: BulletinItemAction) {
		switch action.style {
		case .main:
			let view = BulletinInterfaceBuilder.actionButton(title: action.title)
			view.button.addTarget(self, action: #selector(buttonTouchUpInside(_:)), for: .touchUpInside)
			actions[view.button] = action
			views.append(view)
		case .alternate:
			let button = BulletinInterfaceBuilder.alternativeButton(title: action.title)
			button.addTarget(self, action: #selector(buttonTouchUpInside(_:)), for: .touchUpInside)
			actions[button] = action
			views.append(button)
		}
	}

	@objc private func buttonTouchUpInside(_ sender: UIButton) {
		actions[sender]?.handler?(self)
	}

	deinit {
		print(String(describing: self))
	}
}
