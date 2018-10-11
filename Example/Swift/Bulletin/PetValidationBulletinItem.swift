/**
 *  BulletinBoard
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import UIKit
import BulletinBoard

/**
 * A bulletin page that allows the user to validate its selection.
 *
 * This item demonstrates popping to the previous item, and including a collection view inside the page.
 */

class PetValidationBulletinItem: FeedbackPageBulletinItem {

    var dataSource: CollectionDataSource

    var collectionView: UICollectionView?

    init(dataSource: CollectionDataSource) {
        let selectionFeedbackGenerator = SelectionFeedbackGenerator()
        let successFeedbackGenerator = SuccessFeedbackGenerator()

        self.dataSource = dataSource

        let main = BulletinItemAction(title: "Validate") { (item) in
            // > Play Haptic Feedback

            selectionFeedbackGenerator.selectionChanged()

            // > Display the loading indicator

            item.isLoading = true

            // > Wait for a "task" to complete before displaying the next item

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {

                // Play success haptic feedback

                successFeedbackGenerator.success()

                item.board?.showNext()
            }
        }

        let alternate = BulletinItemAction(title: "Change") { (item) in
            // Play selection haptic feedback

            selectionFeedbackGenerator.selectionChanged()

            // Display previous item

            item.board?.showPrevious()
        }

        let animalType = dataSource.rawValue.capitalized
        super.init(title: "Choose your Favorite",
                   description: "You chose \(animalType) as your favorite animal type. Here are a few examples of posts in this category.",
                   mainAction: main,
                   alternateAction: alternate)

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = 1

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .white

        let collectionWrapper = CollectionViewWrapper(collectionView: collectionView)

        self.collectionView = collectionView
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "ImageCollectionViewCell")
        collectionView.dataSource = self
        collectionView.delegate = self

        views.insert(collectionWrapper, at: 2)
    }
}

 // MARK: - Collection View

extension PetValidationBulletinItem: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(9, dataSource.numberOfImages)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
        cell.imageView.image = dataSource.image(at: indexPath.item)
        cell.imageView.contentMode = .scaleAspectFill
        cell.imageView.clipsToBounds = true

        return cell

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let squareSideLength = (collectionView.frame.width / 3) - 3
        return CGSize(width: squareSideLength, height: squareSideLength)

    }
}

