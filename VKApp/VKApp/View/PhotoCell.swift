//
//  PhotoCell.swift
//  VKApp
//
//  Created by Maxim Safronov on 09.07.2020.
//  Copyright © 2020 Maxim Safronov. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(image)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        configureImgView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    let image = UIImageView()

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .black
        clipsToBounds = true
        layer.cornerRadius = 4
    }
    
    func configureImgView() {
        image.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        image.image = nil
    }
    
    public func configureLargeImageSize(witch photo: Photo) {
        self.image.kf.setImage(with: URL(string: photo.imageURLLargeSize))
    }
    
    public func configureMediumImageSize(witch photo: Photo) {
        self.image.kf.setImage(with: URL(string: photo.imageURLMediumSize))
    }
    
    public func configureSmallImageSize(witch photo: Photo) {
        self.image.kf.setImage(with: URL(string: photo.imageURLSmallSize))
    }
}
