//
//  Session.swift
//  VKApp
//
//  Created by Maxim Safronov on 30.06.2020.
//  Copyright © 2020 Maxim Safronov. All rights reserved.
//

import Foundation

class Session {
    private init() { }
 
    var token: String = ""
    var userId: Int =  0
    
    public static let shared = Session()
}
