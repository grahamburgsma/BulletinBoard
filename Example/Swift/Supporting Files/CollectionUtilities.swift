/**
 *  BulletinBoard
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import UIKit

/**
 * A data provider for a collection view.
 */

enum CollectionDataSource: String {
    case cat, dog

    /// Get the image at the given index.
    func image(at index: Int) -> UIImage {
        let name = "\(rawValue)_img_\(index + 1)"
        return UIImage(named: name)!
    }

    /// The number of images on the data set.
    var numberOfImages: Int {
        return 16
    }

}

// MARK: - ImageCollectionViewCell

/**
 * A collection view cell that displays an image.
 */

class ImageCollectionViewCell: UICollectionViewCell {

    let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        imageView.frame = bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
