//
//  User.swift
//  VKApp
//
//  Created by Maxim Safronov on 30.06.2020.
//  Copyright © 2020 Maxim Safronov. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class User: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var firstName: String = ""
    @objc dynamic var lastName: String = ""
    @objc dynamic var fullName: String { firstName + " " + lastName }
    @objc dynamic var photo100URLString: String = ""
    @objc dynamic var homeTown: String = ""
    let universityName: List<University> = List<University>()
    
    convenience init?(from json: JSON) {
        self.init()
        self.id = json["id"].intValue
        self.firstName = json["first_name"].stringValue
        self.lastName = json["last_name"].stringValue
        self.photo100URLString = json["photo_200"].stringValue
        self.homeTown = json["home_town"].stringValue
        let university = json["universities"].arrayValue.compactMap { University(from: $0) }
        self.universityName.append(objectsIn: university)
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
