/**
 *  BulletinBoard
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import UIKit
import BulletinBoard

/**
 * A set of tools to interact with the demo data.
 *
 * This demonstrates how to create and configure bulletin items.
 */

enum BulletinDataSource {

    // MARK: - Pages

    /**
     * Create the introduction page.
     *
     * This creates a `FeedbackPageBulletinItem` with: a title, an image, a description text and
     * and action button.
     *
     * The action button presents the next item (the textfield page).
     */

	static func makeIntroPage() -> FeedbackPageBulletinItem {

        let mainAction = BulletinItemAction(title: "Configure") { (page) in
            page.board?.showNext()
        }

		let page = FeedbackPageBulletinItem(title: "Welcome to PetBoard",
                                            image: #imageLiteral(resourceName: "RoundedIcon"),
                                            description: "Discover curated images of the best pets in the world.",
                                            mainAction: mainAction)

		page.isDismissable = true

		return page
	}

    /**
     * Create the textfield page.
     *
     * This creates a `TextFieldBulletinPage` with: a title, an error label and a textfield.
     *
     * The keyboard return button presents the next item (the notification page).
     */
    static func makeTextFieldPage() -> TextFieldBulletinPage {

        let mainAction = BulletinItemAction(title: "Done") { (page) in
            page.board?.view.endEditing(true)
            page.board?.showNext()
        }

        let page = TextFieldBulletinPage(title: "Enter your Name",
                                         image: nil,
                                         description: "To create your profile, please tell us your name. We will use it to customize your feed.",
                                         mainAction: mainAction, alternateAction: nil)

        return page

    }

    static func makeDatePage() -> BulletinItem {

        let mainAction = BulletinItemAction(title: "Done") { (item) in
            item.board?.showNext()
        }

        let page = FeedbackPageBulletinItem(title: "Enter Birth Date",
                                    description: "When were you born?",
                                    mainAction: mainAction)

        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        page.views.insert(datePicker, at: 2)

        return page
    }

    /**
     * Create the notifications page.
     *
     * This creates a `FeedbackPageBulletinItem` with: a title, an image, a description text, an action
     * and an alternative button.
     *
     * The action and the alternative buttons present the next item (the location page). The action button
     * starts a notification registration request.
     */

	static func makeNotitificationsPage() -> FeedbackPageBulletinItem {

        let mainAction = BulletinItemAction(title: "Subscribe") { (page) in
            PermissionsManager.shared.requestLocalNotifications()
            page.board?.showNext()
        }

        let alternateAction = BulletinItemAction(title: "Not now") { (page) in
            page.board?.showNext()
        }

        let page = FeedbackPageBulletinItem(title: "Push Notifications",
                                            image: #imageLiteral(resourceName: "NotificationPrompt"),
                                            description: "Receive push notifications when new photos of pets are available.",
                                            mainAction: mainAction,
                                            alternateAction: alternateAction)


		return page
	}

    /**
     * Create the location page.
     *
     * This creates a `FeedbackPageBulletinItem` with: a title, an image, a compact description text,
     * an action and an alternative button.
     *
     * The action and the alternative buttons present the next item (the animal choice page). The action button
     * requests permission for location.
     */

	static func makeLocationPage() -> FeedbackPageBulletinItem {

        let main = BulletinItemAction(title: "Send location data") { (page) in
            PermissionsManager.shared.requestWhenInUseLocation()
            page.board?.showNext()
        }

        let alternate = BulletinItemAction(title: "No thanks") { (page) in
            page.board?.showNext()
        }

        let page = FeedbackPageBulletinItem(title: "Customize Feed",
                                            image:#imageLiteral(resourceName: "LocationPrompt"), description: "We can use your location to customize the feed. This data will be sent to our servers anonymously. You can update your choice later in the app settings.",
                                            mainAction: main,
                                            alternateAction: alternate)


		page.descriptionLabel?.font = .systemFont(ofSize: 15)

		return page
	}

    /**
     * Creates a custom item.
     *
     * The next item is managed by the item itself. See `PetSelectorBulletinPage` for more info.
     */

    static func makeChoicePage() -> PetSelectorBulletinPage {
        return PetSelectorBulletinPage()
    }

    /**
     * Create the location page.
     *
     * This creates a `PageBulletinItem` with: a title, an image, a description text, and an action
     * button. The item can be dismissed. The tint color of the action button is customized.
     *
     * The action button dismisses the bulletin. The alternative button pops to the root item.
     */

    static func makeCompletionPage() -> PageBulletinItem {
        let main = BulletinItemAction(title: "Get started") { (page) in
            page.board?.dismiss(animated: true, completion: nil)
        }

        let alternate = BulletinItemAction(title: "Replay") { (page) in
            page.board?.showFirst()
        }

        let page = FeedbackPageBulletinItem(title: "Setup Completed",
                                            image:#imageLiteral(resourceName: "IntroCompletion"),
                                            description: "PetBoard is ready for you to use. Happy browsing!",
                                            mainAction: main,
                                            alternateAction: alternate)

		page.imageView?.tintColor = #colorLiteral(red: 0.2980392157, green: 0.8509803922, blue: 0.3921568627, alpha: 1)
        page.mainButton?.backgroundColor = #colorLiteral(red: 0.2980392157, green: 0.8509803922, blue: 0.3921568627, alpha: 1)
        page.mainButton?.setTitleColor(.white, for: .normal)

        page.isDismissable = true

        page.dismissalHandler = { item in
            NotificationCenter.default.post(name: .SetupDidComplete, object: item)
        }

        return page

    }

    // MARK: - User Defaults

    /// The current favorite tab index.
    static var favoriteTabIndex: Int {
        get {
            return UserDefaults.standard.integer(forKey: "PetBoardFavoriteTabIndex")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "PetBoardFavoriteTabIndex")
        }
    }

    /// Whether user completed setup.
    static var userDidCompleteSetup: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "PetBoardUserDidCompleteSetup")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "PetBoardUserDidCompleteSetup")
        }
    }
}

// MARK: - Notifications

extension Notification.Name {

    /**
     * The favorite tab index did change.
     *
     * The user info dictionary contains the following values:
     *
     * - `"Index"` = an integer with the new favorite tab index.
     */

    static let FavoriteTabIndexDidChange = Notification.Name("PetBoardFavoriteTabIndexDidChangeNotification")

    /**
     * The setup did complete.
     *
     * The user info dictionary is empty.
     */

    static let SetupDidComplete = Notification.Name("PetBoardSetupDidCompleteNotification")

}
