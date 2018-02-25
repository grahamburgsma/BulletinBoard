import UIKit
import BulletinBoard

/**
 * Returns a list of all the background styles.
 */

func BackgroundStyles() -> [(name: String, style: BulletinBackgroundViewStyle)] {

    var styles: [(name: String, style: BulletinBackgroundViewStyle)] = [
        ("None", .none),
        ("Dimmed", .dimmed)
    ]

	styles.append(("Extra Light", .blurred(style: .extraLight)))
	styles.append(("Light", .blurred(style: .light)))
	styles.append(("Dark", .blurred(style: .dark)))

    return styles

}
