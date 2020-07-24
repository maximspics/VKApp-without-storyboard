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
    @objc dynamic var imageURLLargeSize: String = ""
    @objc dynamic var imageURLMediumSize: String = ""
    @objc dynamic var imageURLSmallSize: String = ""
    @objc dynamic var url: URL? {
        URL(string: imageURLLargeSize)
    }
    @objc dynamic var heightOfLargeImage: Int = 0
    @objc dynamic var widthOfLargeImage: Int = 0
    
    @objc dynamic var heightOfMediumImage: Int = 0
    @objc dynamic var widthOfMediumImage: Int = 0
    
    @objc dynamic var heightOfSmallImage: Int = 0
    @objc dynamic var widthOfSmallImage: Int = 0
    
    var aspectRatio: CGFloat? {
        guard widthOfLargeImage != 0 else { return nil }
        return CGFloat(heightOfLargeImage)/CGFloat(widthOfLargeImage)
    }
    
    convenience init?(from json: JSON) {
        self.init()
        self.id = json["id"].intValue
        self.likesCount = json["count"].intValue
        self.likeUser = json["user_likes"].intValue
        /*
        guard let imageSize = json["sizes"].array?.first(where: { $0["type"] == "s" }) else { return nil }
        self.imageCellURLString = imageSize["url"].stringValue
        
        if let imageCellURLString = json["sizes"].array?.first(where: { $0["type"] == "m" })?["url"].string {
            self.imageCellURLString = imageCellURLString
        }
        */
        let largeSizes = json["sizes"].arrayValue
            .filter({ ["w", "z", "y", "x", "m"].contains($0["type"]) })
            .sorted(by: { $0["width"].intValue * $0["height"].intValue > $1["width"].intValue * $1["height"].intValue })
        
        let firstLargeImage = largeSizes.first
        self.imageURLLargeSize = firstLargeImage?["url"].string ?? ""
        self.widthOfLargeImage = firstLargeImage?["width"].int ?? 0
        self.heightOfLargeImage = firstLargeImage?["height"].int ?? 0
        
        let mediumSizes = json["sizes"].arrayValue
        .filter({ ["s", "m", "x"].contains($0["type"]) })
        .sorted(by: { $0["width"].intValue * $0["height"].intValue > $1["width"].intValue * $1["height"].intValue })
        
        let firstMediumImage = mediumSizes.first
        self.imageURLMediumSize = firstMediumImage?["url"].string ?? ""
        self.widthOfMediumImage = firstMediumImage?["width"].int ?? 0
        self.heightOfMediumImage = firstMediumImage?["height"].int ?? 0
        
        let smallSizes = json["sizes"].arrayValue
        .filter({ ["s", "m", "x"].contains($0["type"]) })
        .sorted(by: { $0["width"].intValue * $0["height"].intValue < $1["width"].intValue * $1["height"].intValue })
        
        let firstSmallImage = smallSizes.first
        self.imageURLSmallSize = firstSmallImage?["url"].string ?? ""
        self.widthOfSmallImage = firstSmallImage?["width"].int ?? 0
        self.heightOfSmallImage = firstSmallImage?["height"].int ?? 0
        
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
