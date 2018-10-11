/**
 *  BulletinBoard
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import UIKit
import BulletinBoard

/**
 * A subclass of page bulletin item that plays an haptic feedback when the buttons are pressed.
 *
 * This class demonstrates how to override `PageBulletinItem` to customize button tap handling.
 */

class FeedbackPageBulletinItem: PageBulletinItem {

    private let feedbackGenerator = SelectionFeedbackGenerator()

    override func buttonTouchUpInside(_ sender: UIButton) {
        super.buttonTouchUpInside(sender)
        feedbackGenerator.selectionChanged()
    }
}
