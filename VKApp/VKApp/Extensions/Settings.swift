//
//  Settings.swift
//  VKApp
//
//  Created by Maxim Safronov on 13.07.2020.
//  Copyright © 2020 Maxim Safronov. All rights reserved.
//

import UIKit

class Settings {
    var records: [Record] = []
    static var shared = Settings()
    let numberOfColumnsCaretaker = NumberOfColumnsCaretaker()
    private init() {
        
        selectedStyle = []
        do {
            self.selectedStyle = try numberOfColumnsCaretaker.load()
        } catch {
            print("Can't load selectedStyle")
        }
    }
    var selectedStyle: [Record] {
        didSet {
            if self.selectedStyle.count > 0 {
                do {
                    try numberOfColumnsCaretaker.save(self.selectedStyle)
                } catch {
                    print("Can't save selectedStyle")
                }
            }
        }
    }
    func addRecord(_ result: FriendsImagesController.PresentationStyle, _ opacity: Float) {
        records.removeAll()
        let record = Record(date: Date(), selectedStyle: result, opacity: opacity)
        self.records.append(record)
    }
    func getSavedRecords(_ savedRecords: [Record]) {
        records.removeAll()
        records.append(contentsOf: savedRecords)
    }
}

struct Record: Codable, Equatable {
    let date: Date
    let selectedStyle: FriendsImagesController.PresentationStyle
    let opacity: Float
}

class NumberOfColumnsCaretaker {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    let key = "numberOfColumns"
    
    func save(_ selectedStyle: [Record]) throws {
        let data: Data = try encoder.encode(selectedStyle)
        UserDefaults.standard.set(data, forKey: key)
    }
    
    func load() throws -> [Record] {
        guard let data = UserDefaults.standard.value(forKey: key) as? Data
            , let selectedStyle = try? decoder.decode([Record].self, from: data) else {
                return []
        }
        return selectedStyle
    }
    
    public enum Error: Swift.Error {
        case selectedStyleNotFound
    }
}
