import UIKit
import BulletinBoard

/**
 * Returns a list of all the background styles.
 */

func BackgroundStyles() -> [(name: String, style: BackgroundView.Style)] {

    var styles: [(name: String, style: BackgroundView.Style)] = [
        ("None", .none),
        ("Dimmed", .dimmed)
    ]

	styles.append(("Extra Light", .blurred(style: .extraLight)))
	styles.append(("Light", .blurred(style: .light)))
	styles.append(("Dark", .blurred(style: .dark)))

    return styles

}
