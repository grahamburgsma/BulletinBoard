/**
 *  BulletinBoard
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import UIKit
import BulletinBoard

/**
 * An item that displays a text field.
 *
 * This item demonstrates how to create a bulletin item with a text field and how it will behave
 * when the keyboard is visible.
 */

class TextFieldBulletinPage: FeedbackPageBulletinItem {

    let textField = UITextField()

    override init(title: String?, image: UIImage?, description: String?, mainAction: BulletinItemAction?, alternateAction: BulletinItemAction?) {
        super.init(title: title, image: image, description: description, mainAction: mainAction, alternateAction: alternateAction)

        textField.delegate = self
        textField.borderStyle = .roundedRect
        views.insert(textField, at: 1)
    }
}

// MARK: - UITextFieldDelegate

extension TextFieldBulletinPage: UITextFieldDelegate {

    @objc open func isInputValid(text: String?) -> Bool {

        if text == nil || text!.isEmpty {
            return false
        }

        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        if isInputValid(text: textField.text) {
            textField.resignFirstResponder()
            return true
        } else {
            descriptionLabel!.textColor = .red
            descriptionLabel!.text = "You must enter some text to continue."
            textField.backgroundColor = UIColor.red.withAlphaComponent(0.3)
            return false
        }
    }
}
