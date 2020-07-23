//
//  Photo.swift
//  VKApp
//
//  Created by Maxim Safronov on 30.06.2020.
//  Copyright © 2020 Maxim Safronov. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

class Photo: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var likesCount: Int = 0
    @objc dynamic var likeUser: Int = 0
    @objc dynamic var imageCellURLString: String = ""
    @objc dynamic var imageURLWithTheLargestSize: String = ""
    @objc dynamic var imageURLWithTheSmallestSize: String = ""
    @objc dynamic var url: URL? {
        URL(string: imageURLWithTheLargestSize)
    }
    @objc dynamic var heightOfLargerImage: Int = 0
    @objc dynamic var widthOfLargerImage: Int = 0
    
    @objc dynamic var heightOfSmallerImage: Int = 0
    @objc dynamic var widthOfSmallerImage: Int = 0
    
    var aspectRatio: CGFloat? {
        guard widthOfLargerImage != 0 else { return nil }
        return CGFloat(heightOfLargerImage)/CGFloat(widthOfLargerImage)
    }
    
    convenience init?(from json: JSON) {
        self.init()
        self.id = json["id"].intValue
        self.likesCount = json["count"].intValue
        self.likeUser = json["user_likes"].intValue
        
        guard let imageSize = json["sizes"].array?.first(where: { $0["type"] == "s" }) else { return nil }
        self.imageCellURLString = imageSize["url"].stringValue
        
        if let imageCellURLString = json["sizes"].array?.first(where: { $0["type"] == "m" })?["url"].string {
            self.imageCellURLString = imageCellURLString
        }
        
        let sizesFromLargerToSmaller = json["sizes"].arrayValue
            .filter({ ["w", "z", "y", "x", "m"].contains($0["type"]) })
            .sorted(by: { $0["width"].intValue * $0["height"].intValue > $1["width"].intValue * $1["height"].intValue })
        
        let firstLargerImage = sizesFromLargerToSmaller.first
        self.imageURLWithTheLargestSize = firstLargerImage?["url"].string ?? ""
        self.widthOfLargerImage = firstLargerImage?["width"].int ?? 0
        self.heightOfLargerImage = firstLargerImage?["height"].int ?? 0
        
        let sizesFromSmallerToLarger = json["sizes"].arrayValue
        .filter({ ["s", "m", "x", "y", "z", "w"].contains($0["type"]) })
        .sorted(by: { $0["width"].intValue * $0["height"].intValue < $1["width"].intValue * $1["height"].intValue })
        
        let firstSmallerImage = sizesFromSmallerToLarger.first
        self.imageURLWithTheSmallestSize = firstSmallerImage?["url"].string ?? ""
        self.widthOfSmallerImage = firstSmallerImage?["width"].int ?? 0
        self.heightOfSmallerImage = firstSmallerImage?["height"].int ?? 0
        
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
