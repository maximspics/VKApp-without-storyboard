//
//  FriendsController.swift
//  VKApp
//
//  Created by Maxim Safronov on 30.06.2020.
//  Copyright © 2020 Maxim Safronov. All rights reserved.
//

import UIKit
import RealmSwift
import Kingfisher

class FriendsController: UIViewController {
    
    let tableView = UITableView()
    var safeArea: UILayoutGuide!
    let searchBar = UISearchBar()
    
    fileprivate lazy var configuration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
    fileprivate lazy var realm = try! Realm(configuration: configuration)
    private let networkService = NetworkService(token: Session.shared.token)
    
    private var friends: Results<User> = try! Realm(configuration: RealmService.deleteIfMigration).objects(User.self)
    var filteredFriends: Results<User>!
    var filteredFriendsFirst: Results<User>!
    
    var filteredFriendsGlobalSearch = [User]()
    
    var trimmedSearchText: String = String()
    var isSearching = false
    var didBeginEditingAndIsEmptyAndDismissKeyBoard = false
    var isHideKeyboardWhenTappedAround = false
    var sections: [String] = []
    var friendsSection = "Мои друзья"
    var friendsGlobalSearchSection = "Глобальный поиск"
    var emptySection = "Ничего не найдено!"
    
    var caretaker = NumberOfColumnsCaretaker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationController()
        saveRealm()
        loadRealm()
        print("viewDidLoad isSearching: \(isSearching)")
        networkService.loadFriends(token: Session.shared.token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(friendsRealm):
                try? RealmService.save(items: friendsRealm, configuration: RealmService.deleteIfMigration, update: .all)
                self.filteredFriends = self.friends
                self.fillSections()
                self.hideKeyboardWhenTappedAround()
                self.loadSelectedStyle()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case let .failure(error):
                print(error)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear isSearching: \(isSearching)")
        search(shouldShow: isSearching)
        searchBar.resignFirstResponder()
        DispatchQueue.main.async {
            if let cancelButton = self.searchBar.value(forKey: "cancelButton") as? UIButton {
                cancelButton.isEnabled = true
            }
        }
        if let index = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: index, animated: true)
        }
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .black
        safeArea = view.layoutMarginsGuide
        configureTableView()
    }
    
    func loadSelectedStyle() {
        let records = try! self.caretaker.load()
        Settings.shared.getSavedRecords(records)
    }
    
    func configureTableView() {
        view.backgroundColor = .black
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.pin(to: view)
        tableView.backgroundColor = .black
        tableView.separatorColor = UIColor.clear
        tableView.tintColor = UIColor.systemGreen
        tableView.register(FriendCell.self, forCellReuseIdentifier: "Cell")
    }
    
    @objc func logOutAlert() {
        let alert = UIAlertController(title: "Внимание!", message: "Ваша сессия будет завершена.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { _ in
            let loginController = LoginController()
            loginController.deleteAllCookies()
            let vc = UINavigationController(rootViewController: loginController)
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        }
        let noAction = UIAlertAction(title: "Отменить", style: .cancel) { _ in
            print("Cookies have not been deleted")
        }
        alert.addAction(okAction)
        alert.addAction(noAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func configureNavigationController() {
        navigationItem.title = "Друзья"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.beautifulGreen]
        
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.tintColor = .beautifulGreen
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .default
        
        searchBar.sizeToFit()
        searchBar.delegate = self
        searchBar.setValue("Отмена", forKey: "cancelButtonText")
        let textField = searchBar.value(forKey: "searchField") as? UITextField
        textField?.textColor = .beautifulGreen
        textField?.backgroundColor = .black
        textField?.layer.borderWidth = 0.2
        textField?.layer.borderColor = UIColor.beautifulGreen.cgColor
        textField?.layer.cornerRadius = 18
        textField?.clipsToBounds = true
        
        let glassIconView = textField?.leftView as! UIImageView
        glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
        glassIconView.tintColor = UIColor.beautifulGreen

        showSearchBarButton(shouldShow: true)
    }
    
    @objc func handleShowSearchBar() {
        search(shouldShow: true)
        searchBar.becomeFirstResponder()
    }
    
    func showSearchBarButton(shouldShow: Bool) {
        if shouldShow {
            let logOutLetfBarItem = UIBarButtonItem(title: "Выйти", style: .plain, target: self,
                                                    action: #selector(logOutAlert))
            navigationItem.leftBarButtonItem = logOutLetfBarItem
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search,
                                                                target: self,
                                                                action: #selector(handleShowSearchBar))
        } else {
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    func search(shouldShow: Bool) {
        showSearchBarButton(shouldShow: !shouldShow)
        searchBar.showsCancelButton = shouldShow
        navigationItem.titleView = shouldShow ? searchBar : nil
    }
    
    func saveRealm() {
        try? realm.write {
            realm.add(friends, update: .all)
        }
        print(realm.configuration.fileURL!)
    }
    
    func loadRealm() {
        let friends = realm.objects(User.self)
        friends.forEach { friend in
            print("loadRealm friends: \nИмя: \(friend.fullName) Город: \(friend.homeTown)")
        }
    }
}

extension FriendsController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        search(shouldShow: false)
        let friendsImagesController = FriendsImagesController()
        let section: String = self.sections[indexPath.section]
        switch section {
        case friendsSection:
            let friend = self.filteredFriends[indexPath.row]
            friendsImagesController.userId = friend.id
            friendsImagesController.fullName = friend.fullName
            self.navigationController?.pushViewController(friendsImagesController, animated: true)
        default:
            let friend = self.filteredFriendsGlobalSearch[indexPath.row]
            friendsImagesController.userId = friend.id
            friendsImagesController.fullName = friend.fullName
            navigationController?.pushViewController(friendsImagesController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section: String = self.sections[section]
        switch section {
        case friendsSection:
            return isSearching ? filteredFriends.count : friends.count
        case friendsGlobalSearchSection:
            return filteredFriendsGlobalSearch.count
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FriendCell
        let view = UIView()
        cell.addSubview(view)
        
        view.pin(to: cell, leading: 20, trailing: -20)
        view.addBorders(edges: [.bottom], color: .cellBorderColor)
        
        let section: String = self.sections[indexPath.section]
        switch section {
        case friendsSection:
            let friend = isSearching ? filteredFriends[indexPath.row] : friends[indexPath.row]
            cell.configureCell(witch: friend)
            return cell
        case friendsGlobalSearchSection:
            let friend = filteredFriendsGlobalSearch[indexPath.row]
            cell.configureCell(witch: friend)
            return cell
        default:
            cell.configureEmptyCell()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
 
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let headerHeight: CGFloat = 43
        let section: String = self.sections[section]
        switch section {
        case friendsSection:
            return headerHeight
        case friendsGlobalSearchSection:
            return headerHeight
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView()
        let label = UILabel()
        
        label.textColor = .sectionHeaderColor
        label.font = UIFont(name: "PT Sans", size: 12)
        view.layer.backgroundColor = UIColor.sectionBackgroundColor.cgColor
        view.clipsToBounds = true
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addBorders(edges: [.top], color: .sectionBorderColor)
        view.addConstraints(withVisualFormat: "H:|-20-[v0]-20-|", views: label)
        view.addConstraints(withVisualFormat: "V:|-0-[v0]-0-|", views: label)
    
        func configureSectionHeader(with text: String){
            label.text = text
        }
        
        let section: String = self.sections[section]
        switch section {
        case friendsSection:
            configureSectionHeader(with: friendsSection)
            return view
        case friendsGlobalSearchSection:
            configureSectionHeader(with: friendsGlobalSearchSection)
            return view
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if didBeginEditingAndIsEmptyAndDismissKeyBoard || (filteredFriends.count == friends.count && didBeginEditingAndIsEmptyAndDismissKeyBoard ) {
            view.alpha = 0
            UIView.animate(withDuration: 0.25) {
                view.alpha = 0.5
            }
        } else {
            view.alpha = 0
            UIView.animate(withDuration: 0) {
                view.alpha = 1.0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if didBeginEditingAndIsEmptyAndDismissKeyBoard || (filteredFriends.count == friends.count && didBeginEditingAndIsEmptyAndDismissKeyBoard ) {
            cell.alpha = 0
            UIView.animate(withDuration: 0.25) {
                cell.alpha = 0.5
            }
        } else {
            let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, 50, 25, 0)
            cell.layer.transform = rotationTransform
            cell.alpha = 0
            UIView.animate(withDuration: 0.5) {
                cell.alpha = 1.0
            }
            UIView.animate(withDuration: 0.25) {
                cell.layer.transform = CATransform3DIdentity
            }
        }
    }
    
    func fillSections() {
        let count = (filteredFriends.count, filteredFriendsGlobalSearch.count)
        switch count {
        case (_, _) where count.0 != 0 && count.1 == 0:
            sections = [friendsSection]
        case (_, _) where count.0 != 0 && count.1 != 0:
            sections = [friendsSection, friendsGlobalSearchSection]
        case (_, _) where count.0 == 0 && count.1 != 0:
            sections = [friendsGlobalSearchSection]
        default:
            sections = [emptySection]
        }
    }
}

extension FriendsController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBarBehavior(searching: isSearching, didBeginEditingAndIsEmptyAndDismissKeyBoard: true, showCancelButton: true)
        tableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        search(shouldShow: false)
        searchBarBehavior(searching: isSearching, didBeginEditingAndIsEmptyAndDismissKeyBoard: false, showCancelButton: false)
        tableView.reloadData()
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        DispatchQueue.main.async {
            if let cancelButton = self.searchBar.value(forKey: "cancelButton") as? UIButton {
                cancelButton.isEnabled = true
            }
        }
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchBarFilter(search: nil)
        } else {
            searchBarFilter(search: searchText)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        search(shouldShow: false)
        searchBar.endEditing(true)
        searchBar.text = ""
        searchBarFilter(search: nil)
        searchBarBehavior(searching: false, didBeginEditingAndIsEmptyAndDismissKeyBoard: false, showCancelButton: false)
        filteredFriendsGlobalSearch.removeAll()
        filteredFriends = friends
        fillSections()
        tableView.reloadData()
    }
    
    private func searchBarFilter(search text: String?) {
        let searchText = text ?? ""
        guard !searchText.isEmpty else {
            searchBarBehavior(searching: isSearching, didBeginEditingAndIsEmptyAndDismissKeyBoard: true, showCancelButton: true)
            filteredFriends = friends
            filteredFriendsGlobalSearch.removeAll()
            fillSections()
            tableView.reloadData()
            return
        }
        trimmedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAndSplitSearchText = trimmedSearchText.split(separator: " ", maxSplits: 1)
        guard trimmedAndSplitSearchText.count != 0 else {
            searchBarBehavior(searching: isSearching, didBeginEditingAndIsEmptyAndDismissKeyBoard: true, showCancelButton: true)
            filteredFriends = friends
            filteredFriendsGlobalSearch.removeAll()
            fillSections()
            tableView.reloadData()
            return
        }
        let first = String(trimmedAndSplitSearchText.first ?? "")
        let last = String(trimmedAndSplitSearchText.last ?? "")
        
        filteredFriendsFirst = friends.filter("(firstName BEGINSWITH[cd] %@ OR lastName BEGINSWITH[cd] %@) OR (firstName BEGINSWITH[cd] %@ OR lastName BEGINSWITH[cd] %@)", first, last, last, first)
        filteredFriends = filteredFriendsFirst
        
        if  trimmedAndSplitSearchText.count == 2 {
            filteredFriends = filteredFriendsFirst.filter("(firstName CONTAINS[cd] %@ AND lastName CONTAINS[cd] %@) OR (firstName CONTAINS[cd] %@ AND lastName CONTAINS[cd] %@)", first, last, last, first)
        }
        networkService.searchFriends(userId: Session.shared.userId, search: trimmedSearchText) { result in
            switch result {
            case let .success(friendsForGlobalSearch):
                self.filteredFriendsGlobalSearch = friendsForGlobalSearch
                self.fillSections()
                guard !friendsForGlobalSearch.isEmpty else {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    return }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case let .failure(error):
                print(error)
            }
        }
        searchBarBehavior(searching: true, didBeginEditingAndIsEmptyAndDismissKeyBoard: false, showCancelButton: true)
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        print("searchBarSearchButtonClicked isSearchng: \(isSearching)")
        search(shouldShow: true)
        searchBar.resignFirstResponder()
    }
    
    func searchBarBehavior(searching: Bool, didBeginEditingAndIsEmptyAndDismissKeyBoard: Bool, showCancelButton: Bool) {
        isSearching = searching
        self.didBeginEditingAndIsEmptyAndDismissKeyBoard = didBeginEditingAndIsEmptyAndDismissKeyBoard
        searchBar.showsCancelButton = showCancelButton
    }
}
extension FriendsController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(FriendsController.dismissKeyboard))
        tap.numberOfTapsRequired = 1
        tap.isEnabled = true
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        
        switch didBeginEditingAndIsEmptyAndDismissKeyBoard {
        case true:
            print("isHideKeyboardWhenTappedAround true isSearchng: \(isSearching)")
            self.searchBar.endEditing(true)
            search(shouldShow: isSearching)
        case false: break
        }
    }
}
