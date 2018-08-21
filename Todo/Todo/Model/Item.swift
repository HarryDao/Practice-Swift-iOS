//
//  Item.swift
//  Todo
//
//  Created by Chuck Fishman on 19/08/18.
//  Copyright © 2018 Chuck Fishman. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title = ""
    @objc dynamic var done = false
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
