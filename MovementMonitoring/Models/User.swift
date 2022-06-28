//
//  User.swift
//  MovementMonitoring
//
//  Created by Eduard on 01.06.2022.
//

import UIKit
import RealmSwift

class User: Object {
    @objc dynamic var login = ""
    @objc dynamic var password = ""
    
    override class func primaryKey() -> String? {
        "login"
    }
    
    convenience init(login: String, password: String ) {
    self.init()
        self.login = login
        self.password = password
    }
}
