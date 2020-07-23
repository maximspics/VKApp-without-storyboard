//
//  NetworkService.swift
//  VKApp
//
//  Created by Maxim Safronov on 30.06.2020.
//  Copyright © 2020 Maxim Safronov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CommonCrypto

class NetworkService {

    static let session: Alamofire.SessionManager = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 20
        let session = Alamofire.SessionManager(configuration: config)
        return session
    }()
    
    private let baseUrl = "https://api.vk.com"
    private let versionAPI = "5.92"
    
    private let token: String
    
    init(token: String) {
        self.token = token
    }
    
    func loadFriends(token: String, completion: ((Swift.Result<[User], Error>) -> Void)? = nil) {
        //  let baseUrl = "https://api.vk.com"
        let path = "/method/friends.get"
        let params: Parameters = [
            "access_token": token,
            "fields": "first_name, last_name, photo_200, home_town, universities",
            "v": versionAPI
        ]
        NetworkService.session.request(baseUrl + path, method: .get, parameters: params).responseJSON { response in
            switch response.result {
            case let .success(token):
                let json = JSON(token)
                let friendJSONs = json["response"]["items"].arrayValue
                let universities = friendJSONs.flatMap { friendJson in
                    friendJson["universities"].arrayValue.compactMap { universityJson in
                        University(from: universityJson)
                    }
                }
                let universitiesNames = universities.map { $0.name }
                let uniqueUniversities = Set(universitiesNames)
                print(uniqueUniversities)
                let friends = friendJSONs.compactMap { User(from: $0) }
                completion?(.success(friends))
            case let .failure(error):
                completion?(.failure(error))
            }
        }
    }
    
    func searchFriends(userId: Int, search: String, completion: ((Swift.Result<[User], Error>) -> Void)? = nil) {
        let path = "/method/users.search"
        let params: Parameters = [
            "access_token": token,
            "fields": "first_name, last_name, photo_200, home_town, universities",
            "q": search,
            "count": 20,
            "v": versionAPI
        ]
        NetworkService.session.request(baseUrl + path, method: .get, parameters: params).responseJSON { response in
            switch response.result {
            case let .success(token):
                let json = JSON(token)
                let friendJSONs = json["response"]["items"].arrayValue
                let universities = friendJSONs.flatMap { friendJson in
                    friendJson["universities"].arrayValue.compactMap { universityJson in
                        University(from: universityJson)
                    }
                }
                let universitiesNames = universities.map { $0.name }
                let uniqueUniversities = Set(universitiesNames)
                print(uniqueUniversities)
                let friends = friendJSONs.compactMap { User(from: $0) }
                completion?(.success(friends))
            case let .failure(error):
                completion?(.failure(error))
            }
        }
    }
    
    func loadPhotos(userId: Int, completion: ((Swift.Result<[Photo], Error>) -> Void)? = nil) {
        let path = "/method/photos.getAll"
        let params: Parameters = [
            "access_token": token,
            "owner_id": userId,
            "count": 200,
            "extended": 1,
            "v": versionAPI
        ]
        
        NetworkService.session.request(baseUrl + path, method: .get, parameters: params).responseJSON { response in
            switch response.result {
            case let .success(data):
                let json = JSON(data)
                let friendJSONs = json["response"]["items"].arrayValue
                let photos = friendJSONs.compactMap { Photo(from: $0) }
                completion?(.success(photos))
            case let .failure(error):
                completion?(.failure(error))
            }
        }
    }
}
