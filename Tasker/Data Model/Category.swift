//
//  Category.swift
//  Tasker
//
//  Created by ADELU ABIDEEN ADELEYE on 8/5/18.
//  Copyright © 2018 Spantom Technologies Ltd. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var colour: String = ""
    
    let tasks = List<Task>()
    
}
