//
//  ItemAction.swift
//  BulletinBoard
//
//  Created by Graham Burgsma on 2018-01-13.
//  Copyright © 2018 Bulletin. All rights reserved.
//

import Foundation

public enum BulletinItemActionStyle {
	case main, alternate
}

public class BulletinItemAction: NSObject {

	public let title: String?
	public let style: BulletinItemActionStyle
	public var handler: ((BulletinItem) -> Void)?

	public init(title: String?, style: BulletinItemActionStyle, handler: ((BulletinItem) -> Void)?) {
		self.title = title
		self.style = style
		self.handler = handler
	}
}
