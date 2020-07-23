//
//  RealmService.swift
//  VKApp
//
//  Created by Maxim Safronov on 30.06.2020.
//  Copyright © 2020 Maxim Safronov. All rights reserved.
//

import Foundation
import RealmSwift

class RealmService {
    static let deleteIfMigration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
    
    static func get<T: Object>(_ type: T.Type) throws -> Results<T> {
        let realm = try Realm(configuration: deleteIfMigration)
        return realm.objects(type)
    }
    
    static func save<T: Object>(items: [T],
        configuration: Realm.Configuration = deleteIfMigration,
        update: Realm.UpdatePolicy = .all) throws {
        let realm = try Realm(configuration: configuration)
        print(configuration.fileURL ?? "")
        try realm.write {
            realm.add(items, update: update)
        }
    }
    
    static func service () throws -> Realm {
        return try Realm(configuration: deleteIfMigration)
    }
}
