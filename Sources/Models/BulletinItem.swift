/**
 *  BulletinBoard
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import UIKit

/**
 * An item that can be displayed inside a bulletin card.
 */

@objc public protocol BulletinItem: class {

	weak var board: BulletinBoard? { get set }

    /**
     * Whether the page can be dismissed.
     *
     * If you set this value to `true`, the user will be able to dismiss the bulletin by tapping outside
     * of the card or by swiping down.
     *
     * You should set it to `true` for the last item you want to display, or for items that start an optional flow
     * (ex: a purchase).
     */

    var isDismissable: Bool { get set }

    /**
     * Whether the item should move with the keyboard.
     *
     * You must set it to `true` if the item displays a text field. Otherwise, you can set it to `false` if you
     * don't want the bulletin to move when system alerts are displayed.
     */

    var shouldRespondToKeyboardChanges: Bool { get set }

    /**
     * The block of code to execute when the bulletin item is dismissed. This is called after the bulletin
     * is moved out of view.
     *
     * - parameter item: The item that is being dismissed.

     * When calling `dismissalHandler`, the manager passes a reference to `self` so you don't have to retain a
     * weak reference yourself.
     */

    var dismissalHandler: ((_ item: BulletinItem) -> Void)? { get set }

    // MARK: - Interface

    /**
     * Creates the list of views to display inside the bulletin card.
     *
     * The views will be arranged vertically, in the order they are stored in the return array.
     */

    func makeArrangedSubviews() -> [UIView]

    /**
     * Called by the manager when the item was removed from the bulletin.
     *
     * Use this function to remove any button target or gesture recognizers from your managed views, and
     * deallocate any resources created for this item that are no longer needed.
     */

    func tearDown()

}
