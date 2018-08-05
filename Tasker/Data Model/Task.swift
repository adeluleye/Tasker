//
//  Task.swift
//  Tasker
//
//  Created by ADELU ABIDEEN ADELEYE on 8/5/18.
//  Copyright © 2018 Spantom Technologies Ltd. All rights reserved.
//

import Foundation
import RealmSwift

class Task: Object {
    
    // Create properties using Realm with the 'dynamic' keyword @objc
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    
    var parentCategory = LinkingObjects(fromType: Category.self, property: "tasks")
}
