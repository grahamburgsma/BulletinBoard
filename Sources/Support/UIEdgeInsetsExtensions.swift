//
//  UIEdgeInsetsExtensions.swift
//
//  Created by Graham Burgsma on 2018-06-26.
//

import UIKit

extension UIEdgeInsets {

    static func + (left: UIEdgeInsets, right: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(top: left.top + right.top,
                            left: left.left + right.left,
                            bottom: left.bottom + right.bottom,
                            right: left.right + right.right)
    }

    static func += (left: inout UIEdgeInsets, right: UIEdgeInsets) {
        left = left + right
    }

    static func - (left: UIEdgeInsets, right: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(top: left.top - right.top,
                            left: left.left - right.left,
                            bottom: left.bottom - right.bottom,
                            right: left.right - right.right)
    }

    static func -= (left: inout UIEdgeInsets, right: UIEdgeInsets) {
        left = left - right
    }
}
