//
//  FriendsImagesController.swift
//  VKApp
//
//  Created by Maxim Safronov on 09.07.2020.
//  Copyright © 2020 Maxim Safronov. All rights reserved.
//

import UIKit
import RealmSwift

class FriendsImagesController: UIViewController {
    
    private let networkService = NetworkService(token: Session.shared.token)
    var caretaker = NumberOfColumnsCaretaker()
    
    var collectionView: UICollectionView!
    var safeArea: UILayoutGuide!
    var userId = Int()
    var fullName = String()
    var photos = [Photo]()
    
    let buttonsBackgroundView = UIView()
    let increaseButton = IncreaseButtonView()
    let decreaseButton = DecreaseButtonView()
  
    enum PresentationStyle: String, CaseIterable, Codable {
        case oneColumn
        case threeColumns
        case fiveColumns
        case nineColumns
    }
    
    var styleDelegates: [PresentationStyle: CollectionViewSelectableItemDelegate] = {
        let result: [PresentationStyle: CollectionViewSelectableItemDelegate] = [
            .oneColumn: OneColumnCollectionViewDelegate(),
            .threeColumns: ThreeColumnsCollectionViewDelegate(),
            .fiveColumns: FiveColumnsCollectionViewDelegate(),
            .nineColumns: NineColumnsCollectionViewDelegate(),
        ]
        result.values.forEach {
            $0.didSelectItem = { _ in
                print("Item selected")
            }
        }
        return result
    }()
    
    var selectedStyle: PresentationStyle! {
        didSet { updatePresentationStyle() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateButtonsStyle()
        networkService.loadPhotos(userId: userId) { result in
            switch result {
            case let .success(photos):
                self.photos = photos
                self.configureNavigationController()
                DispatchQueue.main.async {
                    self.updatePresentationStyle()
                }
            case let .failure(error):
                print(error)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
        configureCollectionView()
    }
    
    func updatePresentationStyle() {
        if Settings.shared.records.count > 0 {
            let getLastRecord = Settings.shared.records[Settings.shared.records.count - 1]
            collectionView.delegate = styleDelegates[getLastRecord.selectedStyle]
            updateButtonsStyle()
            collectionView.performBatchUpdates({
                self.reloadItems()
            }, completion: nil)
        } else {
            collectionView.delegate = styleDelegates[.threeColumns]
            Settings.shared.addRecord(.threeColumns, 1.0)
            collectionView.performBatchUpdates({
                self.collectionView.reloadData()
            }, completion: nil)
        }
    }
    
    func updateButtonsStyle() {
        if Settings.shared.records.count > 0 {
            let getLastRecord = Settings.shared.records[Settings.shared.records.count - 1]
            let allCases = PresentationStyle.allCases
            let index = allCases.firstIndex(of: getLastRecord.selectedStyle)
            if index == 0 {
                increaseButton.layer.opacity = 0.5
            } else if index == allCases.count - 1 {
                decreaseButton.layer.opacity = 0.5
            } else {
                increaseButton.layer.opacity = 1.0
                decreaseButton.layer.opacity = 1.0
            }
        }
    }
    
    func configureNavigationController() {
        navigationItem.title = fullName
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.beautifulGreen]
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.tintColor = .beautifulGreen
        navigationController?.navigationBar.isTranslucent = false
    }
    
    func configureCollectionView() {
        let view = UIView()
        view.backgroundColor = .black
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.backgroundColor = UIColor.black
        view.addSubview(collectionView)
        self.view = view
        collectionView.pin(to: view)
        
        view.addSubview(buttonsBackgroundView)
        buttonsBackgroundView.clipsToBounds = true
        buttonsBackgroundView.layer.cornerRadius = 13
        buttonsBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        buttonsBackgroundView.topAnchor.constraint(equalTo: collectionView.topAnchor, constant: 5).isActive = true
        buttonsBackgroundView.heightAnchor.constraint(equalToConstant: 26).isActive = true
        buttonsBackgroundView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        buttonsBackgroundView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor, constant: collectionView.bounds.width - 75).isActive = true
        
        buttonsBackgroundView.addSubview(increaseButton)
        increaseButton.backgroundColor = .clear
        increaseButton.translatesAutoresizingMaskIntoConstraints = false
        increaseButton.topAnchor.constraint(equalTo: buttonsBackgroundView.topAnchor, constant: 1.5).isActive = true
        increaseButton.bottomAnchor.constraint(equalTo: buttonsBackgroundView.bottomAnchor, constant: 1.5).isActive = true
        increaseButton.heightAnchor.constraint(equalToConstant: 23).isActive = true
        increaseButton.widthAnchor.constraint(equalToConstant: 23).isActive = true
        increaseButton.leadingAnchor.constraint(equalTo: buttonsBackgroundView.leadingAnchor, constant: 5).isActive = true
        
        buttonsBackgroundView.addSubview(decreaseButton)
        decreaseButton.backgroundColor = .clear
        decreaseButton.translatesAutoresizingMaskIntoConstraints = false
        decreaseButton.topAnchor.constraint(equalTo: buttonsBackgroundView.topAnchor, constant: 1.5).isActive = true
        decreaseButton.bottomAnchor.constraint(equalTo: buttonsBackgroundView.bottomAnchor, constant: 1.5).isActive = true
        decreaseButton.heightAnchor.constraint(equalToConstant: 23).isActive = true
        decreaseButton.widthAnchor.constraint(equalToConstant: 23).isActive = true
        decreaseButton.trailingAnchor.constraint(equalTo: buttonsBackgroundView.trailingAnchor, constant: -5).isActive = true
        
        let gestureDecreaseSizeOfImages = UITapGestureRecognizer(target: self, action: #selector(increaseNumberOfColumns))
        decreaseButton.addGestureRecognizer(gestureDecreaseSizeOfImages)
        let gestureIncreaseSizeOfImages = UITapGestureRecognizer(target: self, action: #selector(decreaseNumberOfColumns))
        increaseButton.addGestureRecognizer(gestureIncreaseSizeOfImages)
        
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = buttonsBackgroundView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        buttonsBackgroundView.addSubview(blurEffectView)
        buttonsBackgroundView.sendSubviewToBack(blurEffectView)
        
        let blurEffectButton = UIBlurEffect(style: .systemUltraThinMaterialLight)
        let blurEffectViewButton = UIVisualEffectView(effect: blurEffectButton)
        blurEffectViewButton.frame = decreaseButton.bounds
        blurEffectViewButton.frame = increaseButton.bounds
        blurEffectViewButton.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    @objc func increaseNumberOfColumns() {
        let allCases = PresentationStyle.allCases
        let getLastRecord = Settings.shared.records[Settings.shared.records.count - 1]
        guard let index = allCases.firstIndex(of: getLastRecord.selectedStyle) else { return }
        let opacity: Float = index == allCases.count - 1 ? 0.5 : 1.0
        if index == allCases.count - 1 {
            decreaseButton.layer.opacity = opacity
            selectedStyle = allCases[index]
        } else {
            increaseButton.layer.opacity = opacity
            let nextIndex = (index + 1) % allCases.count
            selectedStyle = allCases[nextIndex]
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                let scale1 = CATransform3DMakeScale(0.9, 0.9, 0.1)
                self.buttonsBackgroundView.layer.transform = scale1
            }, completion: { finished in
            })
            UIView.animate(withDuration: 0.25, delay: 0.125, options: .curveEaseOut, animations: {
                let scale1 = CATransform3DMakeScale(1, 1, 1)
                self.buttonsBackgroundView.layer.transform = scale1
            }, completion: { finished in
            })
        }
        Settings.shared.addRecord(selectedStyle, opacity)
        try! self.caretaker.save(Settings.shared.records)
        updatePresentationStyle()
    }
    
    @objc func decreaseNumberOfColumns(with buttonsBackgroundView: UIView) {
        let allCases = PresentationStyle.allCases
        let getLastRecord = Settings.shared.records[Settings.shared.records.count - 1]
        guard let index = allCases.firstIndex(of: getLastRecord.selectedStyle) else { return }
        let opacity: Float = index == 0 ? 0.5 : 1.0
        if index == 0 {
            increaseButton.layer.opacity = opacity
            let nextIndex = (index) % allCases.count
            selectedStyle = allCases[nextIndex]
        } else {
            decreaseButton.layer.opacity = opacity
            let nextIndex = (index - 1) % allCases.count
            selectedStyle = allCases[nextIndex]
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                let scale1 = CATransform3DMakeScale(0.9, 0.9, 0.9)
                self.buttonsBackgroundView.layer.transform = scale1
            }, completion: { finished in
            })
            UIView.animate(withDuration: 0.25, delay: 0.125, options: .curveEaseOut, animations: {
                let scale1 = CATransform3DMakeScale(1, 1, 1)
                self.buttonsBackgroundView.layer.transform = scale1
            }, completion: { finished in
            })
        }
        Settings.shared.addRecord(selectedStyle, opacity)
        try! self.caretaker.save(Settings.shared.records)
        updatePresentationStyle()
    }
}

extension FriendsImagesController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PhotoCell
        cell.superview?.bringSubviewToFront(cell)
        cell.addBorders(edges: [.all], color: .cellBorderColor, inset: -5, thickness: 1)
        let photo = self.photos[indexPath.item]
        if Settings.shared.records.count > 0 {
            let getLastRecord = Settings.shared.records[Settings.shared.records.count - 1]
            switch getLastRecord.selectedStyle {
            case _ where getLastRecord.selectedStyle == .oneColumn:
                cell.configureLargeImageSize(witch: photo)
            case _ where getLastRecord.selectedStyle == .threeColumns || getLastRecord.selectedStyle == .fiveColumns:
                cell.configureMediumImageSize(witch: photo)
            default:
                cell.configureSmallImageSize(witch: photo)
            }
        } else {
            cell.configureMediumImageSize(witch: photo)
        }
        return cell
    }
    
    func reloadItems() {
        let indexPath = collectionView.indexPathsForVisibleItems
        collectionView.reloadItems(at: indexPath)
    }
}
