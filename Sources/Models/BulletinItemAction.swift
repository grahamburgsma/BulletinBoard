//
//  ItemAction.swift
//  BulletinBoard
//
//  Created by Graham Burgsma on 2018-01-13.
//  Copyright © 2018 Bulletin. All rights reserved.
//

import Foundation

public class BulletinItemAction: NSObject {

	public let title: String?
	public var handler: ((BulletinItem) -> Void)?

	public init(title: String?, handler: ((BulletinItem) -> Void)?) {
		self.title = title
		self.handler = handler
	}
}
