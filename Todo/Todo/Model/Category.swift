//
//  Category.swift
//  Todo
//
//  Created by Chuck Fishman on 19/08/18.
//  Copyright © 2018 Chuck Fishman. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name = ""
    @objc dynamic var color = ""
    var items = List<Item>()
}
