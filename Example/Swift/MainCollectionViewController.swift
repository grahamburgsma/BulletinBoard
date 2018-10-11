/**
 *  BulletinBoard
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import UIKit
import BulletinBoard

/**
 * A view controller displaying a set of images.
 *
 * This demonstrates how to set up a bulletin manager and present the bulletin.
 */

final class MainCollectionViewController: UICollectionViewController {

    @IBOutlet private weak var styleButtonItem: UIBarButtonItem!
    @IBOutlet private weak var segmentedControl: UISegmentedControl!

    /// The data provider for the collection view.
    private lazy var dataSource: CollectionDataSource = {
        return BulletinDataSource.favoriteTabIndex == 0 ? .cat : .dog
    }()

    /// Whether the status bar should be hidden.
    private var shouldHideStatusBar: Bool = false

    // MARK: - Customization

    let backgroundStyles = BackgroundStyles()

    /// The current background style.
    var currentBackground = (name: "Dimmed", style: BackgroundView.Style.dimmed)

    // MARK: - Bulletin Manager

    /**
     * Configures the bulletin manager.
     *
     * We first need to create the first bulletin item we want to display. Then, we use it to create
     * the bulletin manager.
     */

    // MARK: - View

    override func viewDidLoad() {

        super.viewDidLoad()
        prepareForBulletin()

        segmentedControl.selectedSegmentIndex = BulletinDataSource.favoriteTabIndex

        styleButtonItem.title = currentBackground.name
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Bulletin

    /**
     * Prepares the view controller for the bulletin interface.
     */

    func prepareForBulletin() {

        // Register notification observers

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setupDidComplete),
                                               name: .SetupDidComplete,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(favoriteIndexDidChange(notification:)),
                                               name: .FavoriteTabIndexDidChange,
                                               object: nil)

        // If the user did not complete the setup, present the bulletin automatically

        if !BulletinDataSource.userDidCompleteSetup {
            showBulletin()
        }
    }

    /**
     * Displays the bulletin.
     */

    func showBulletin() {

		let bulletinBoard = BulletinBoard(items: [
			BulletinDataSource.makeIntroPage(),
            BulletinDataSource.makeTextFieldPage(),
			BulletinDataSource.makeNotitificationsPage(),
			BulletinDataSource.makeLocationPage(),
//			BulletinDataSource.makeChoicePage(),
			BulletinDataSource.makeCompletionPage()
			])

        bulletinBoard.backgroundViewStyle = currentBackground.style

		present(bulletinBoard, animated: true, completion: nil)
    }

    // MARK: - Actions

    @IBAction func styleButtonTapped(_ sender: Any) {

        let styleSelectorSheet = UIAlertController(title: "Bulletin Background Style",
                                                   message: nil,
                                                   preferredStyle: .actionSheet)

        for backgroundStyle in backgroundStyles {

            let action = UIAlertAction(title: backgroundStyle.name, style: .default) { _ in
                self.styleButtonItem.title = backgroundStyle.name
                self.currentBackground = backgroundStyle
            }

            let isSelected = backgroundStyle.name == currentBackground.name
            action.setValue(isSelected, forKey: "checked")

            styleSelectorSheet.addAction(action)

        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        styleSelectorSheet.addAction(cancelAction)

        styleSelectorSheet.popoverPresentationController?.barButtonItem = styleButtonItem
        present(styleSelectorSheet, animated: true)

    }

    @IBAction func showIntroButtonTapped(_ sender: UIBarButtonItem) {
        showBulletin()
    }

    @IBAction func tabIndexChanged(_ sender: UISegmentedControl) {
        updateTab(sender.selectedSegmentIndex)
    }

    @objc func fontButtonItemTapped(sender: UIBarButtonItem) {
        BulletinDataSource.useAvenirFont = !BulletinDataSource.useAvenirFont
        sender.title = BulletinDataSource.currentFontName()
    }

    @objc func fullScreenButtonTapped(sender: UIBarButtonItem) {
        shouldHideStatusBar = !shouldHideStatusBar
        sender.title = shouldHideStatusBar ? "Status Bar: OFF" : "Status Bar: ON"
    }

    // MARK: - Notifications

    @objc func setupDidComplete() {
        BulletinDataSource.userDidCompleteSetup = true
    }

    @objc func favoriteIndexDidChange(notification: Notification) {

        guard let newIndex = notification.userInfo?["Index"] as? Int else {
            return
        }

        updateTab(newIndex)

    }

    /**
     * Update the selected tab.
     */

    private func updateTab(_ newIndex: Int) {

        segmentedControl.selectedSegmentIndex = newIndex
        dataSource = newIndex == 0 ? .cat : .dog
        BulletinDataSource.favoriteTabIndex = newIndex

        collectionView.reloadData()

    }

}

// MARK: - Collection View

extension MainCollectionViewController: UICollectionViewDelegateFlowLayout {

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.numberOfImages
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageCollectionViewCell
        cell.imageView.image = dataSource.image(at: indexPath.row)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let image = dataSource.image(at: indexPath.row)
        let aspectRatio = image.size.height / image.size.width

        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let width = collectionView.frame.inset(by: layout.sectionInset).width
        let height = width * aspectRatio

        return CGSize(width: width, height: height)
    }
}
