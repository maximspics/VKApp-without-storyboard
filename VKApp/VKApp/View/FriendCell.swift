//
//  FriendCell.swift
//  VKApp
//
//  Created by Maxim Safronov on 01.07.2020.
//  Copyright © 2020 Maxim Safronov. All rights reserved.
//

import UIKit

class FriendCell: UITableViewCell {
    
    var stackView = UIStackView()
    var userImage = UIImageView()
    var fullNameLabel = UILabel()
    var homeTownLabel = UILabel()
    var universityLabel = UILabel()
    var usersNotFound = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(userImage)
        addSubview(stackView)
        addSubview(usersNotFound)
        
        configureUserImage()
        configureFullNameLabel()
        configureHomeTownLabel()
        configureUniversityLabel()
        configureUsersNotFound()
        
        setImageConstraints()
        
        stackView.axis = .vertical
        stackView.distribution = .equalCentering
        stackView.spacing = 0
        setStackViewConstraints()
        addLabelsToStackView()
        setUsersNotFoundConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        contentView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
    }
    
    func configureUserImage() {
        userImage.layer.cornerRadius = userImage.layer.frame.width/2
        userImage.contentMode = .scaleAspectFill
        userImage.layer.borderWidth = 1
        userImage.layer.borderColor = UIColor.systemGreen.cgColor
        userImage.layer.cornerRadius = 22
        userImage.clipsToBounds = true
    }
    
    func configureFullNameLabel(){
        fullNameLabel.textAlignment = .left
        fullNameLabel.font = UIFont.boldSystemFont(ofSize: 12)
        fullNameLabel.textColor = UIColor.systemGreen
        fullNameLabel.layer.opacity = 0.85
    }
    
    func configureHomeTownLabel(){
        homeTownLabel.textAlignment = .left
        homeTownLabel.font = UIFont.boldSystemFont(ofSize: 10)
        homeTownLabel.textColor = UIColor.systemGreen
        homeTownLabel.layer.opacity = 0.5
    }
    
    func configureUniversityLabel(){
        universityLabel.textAlignment = .left
        universityLabel.font = UIFont.boldSystemFont(ofSize: 8)
        universityLabel.textColor = UIColor.systemGreen
        universityLabel.layer.opacity = 0.75
    }
    
    func configureUsersNotFound(){
        usersNotFound.textAlignment = .left
        usersNotFound.font = UIFont.boldSystemFont(ofSize: 12)
        usersNotFound.textColor = UIColor.systemGreen
        usersNotFound.layer.opacity = 0.85
    }
    
    func setImageConstraints() {
        userImage.translatesAutoresizingMaskIntoConstraints = false
        userImage.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        userImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        userImage.heightAnchor.constraint(equalToConstant: 44).isActive = true
        userImage.widthAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    func setStackViewConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: userImage.trailingAnchor, constant: 15).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
    }
    
    func addLabelsToStackView() {
        let labels: [UIView] = [fullNameLabel, homeTownLabel, universityLabel]
        for label in labels {
            stackView.addArrangedSubview(label)
        }
    }
    
    func setUsersNotFoundConstraints() {
        usersNotFound.translatesAutoresizingMaskIntoConstraints = false
        usersNotFound.topAnchor.constraint(equalTo: topAnchor, constant: 14).isActive = true
        usersNotFound.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
    
    override func prepareForReuse() {
    super.prepareForReuse()
        fullNameLabel.text = nil
        fullNameLabel.isHidden = false
        
        homeTownLabel.text = nil
        homeTownLabel.isHidden = false
        
        universityLabel.text = nil
        universityLabel.isHidden = false
        
        userImage.image = nil
        userImage.isHidden = false
        
        usersNotFound.text = nil
        usersNotFound.isHidden = false
    }
    
    public func configureCell(witch friend: User) {
        self.fullNameLabel.text = friend.fullName
        self.homeTownLabel.text = friend.homeTown
        self.userImage.kf.setImage(with: URL(string: friend.photo100URLString))
        
        if let universityName = friend.universityName.first?.name {
            self.universityLabel.text = universityName
        } else {
            self.universityLabel.isHidden = true
        }
    }
    
    public func configureEmptyCell() {
        self.userImage.isHidden = true
        self.usersNotFound.text = "ни одного человека"
    }
}
