/**
 *  BulletinBoard
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import UIKit
import BulletinBoard

/**
 * An item that displays a choice with two buttons.
 *
 * This item demonstrates how to create a page bulletin item with a custom interface, and changing the
 * next item based on user interaction.
 */

class PetSelectorBulletinPage: FeedbackPageBulletinItem {

    private var catButton: UIButton!
    private var dogButton: UIButton!
    private var selectionFeedbackGenerator = SelectionFeedbackGenerator()

    // MARK: - BulletinItem

    init() {
        let mainAction = BulletinItemAction(title: "Select") { (item) in
            item.board?.showNext()
        }

        super.init(title: "Choose your Favorite", description: "Your favorite pets will appear when you open the app.", mainAction: mainAction)

        let favoriteTabIndex = BulletinDataSource.favoriteTabIndex

        catButton = createChoiceCell(dataSource: .cat, isSelected: favoriteTabIndex == 0)
        catButton.addTarget(self, action: #selector(catButtonTapped), for: .touchUpInside)

        dogButton = createChoiceCell(dataSource: .dog, isSelected: favoriteTabIndex == 1)
        dogButton.addTarget(self, action: #selector(dogButtonTapped), for: .touchUpInside)

        let petsStackView = UIStackView(arrangedSubviews: [catButton, dogButton])
        petsStackView.axis = .vertical
        petsStackView.spacing = 16
        views.insert(petsStackView, at: 2)
    }

    deinit {
        catButton?.removeTarget(self, action: nil, for: .touchUpInside)
        dogButton?.removeTarget(self, action: nil, for: .touchUpInside)
    }


    // MARK: - Custom Views

    /**
     * Creates a custom choice cell.
     */

    func createChoiceCell(dataSource: CollectionDataSource, isSelected: Bool) -> UIButton {

        let emoji: String
        let animalType: String

        switch dataSource {
        case .cat:
            emoji = "🐱"
            animalType = "Cats"
        case .dog:
            emoji = "🐶"
            animalType = "Dogs"
        }

        let button = UIButton(type: .system)
        button.setTitle(emoji + " " + animalType, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        button.contentHorizontalAlignment = .center
        button.accessibilityLabel = animalType

        button.layer.cornerRadius = 12
        button.layer.borderWidth = 2

        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        let heightConstraint = button.heightAnchor.constraint(equalToConstant: 55)
        heightConstraint.priority = .defaultHigh
        heightConstraint.isActive = true

        let buttonColor: UIColor = isSelected ? #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1) : .lightGray
        button.layer.borderColor = buttonColor.cgColor
        button.setTitleColor(buttonColor, for: .normal)
        button.layer.borderColor = buttonColor.cgColor

        return button

    }

    // MARK: - Touch Events

    /// Called when the cat button is tapped.
    @objc func catButtonTapped() {

        // Play haptic feedback

        selectionFeedbackGenerator.selectionChanged()

        // Update UI

        let catButtonColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        catButton.layer.borderColor = catButtonColor.cgColor
        catButton.setTitleColor(catButtonColor, for: .normal)

        let dogButtonColor = UIColor.lightGray
        dogButton?.layer.borderColor = dogButtonColor.cgColor
        dogButton?.setTitleColor(dogButtonColor, for: .normal)

        // Send a notification to inform observers of the change

        NotificationCenter.default.post(name: .FavoriteTabIndexDidChange,
                                        object: self,
                                        userInfo: ["Index": 0])
    }

    /// Called when the dog button is tapped.
    @objc func dogButtonTapped() {

        // Play haptic feedback

        selectionFeedbackGenerator.selectionChanged()

        // Update UI

        let catButtonColor = UIColor.lightGray
        catButton?.layer.borderColor = catButtonColor.cgColor
        catButton?.setTitleColor(catButtonColor, for: .normal)

        let dogButtonColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        dogButton.layer.borderColor = dogButtonColor.cgColor
        dogButton.setTitleColor(dogButtonColor, for: .normal)

        // Send a notification to inform observers of the change

        NotificationCenter.default.post(name: .FavoriteTabIndexDidChange,
                                        object: self,
                                        userInfo: ["Index": 1])
    }
}
