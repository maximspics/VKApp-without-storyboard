//
//  University.swift
//  VKApp
//
//  Created by Maxim Safronov on 30.06.2020.
//  Copyright © 2020 Maxim Safronov. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

class University: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    
    convenience init?(from json: JSON) {
        self.init()
        self.id = json["id"].intValue
        guard let name = json["name"].string else { return nil }
        self.name = name
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
