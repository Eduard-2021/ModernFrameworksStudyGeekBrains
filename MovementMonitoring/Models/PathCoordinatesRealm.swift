//
//  PathCoordinates.swift
//  MovementMonitoring
//
//  Created by Eduard on 10.04.2022.
//

import UIKit
import RealmSwift

class PathCoordinatesRealm: Object {
    @objc dynamic var latitude = 0.0
    @objc dynamic var longitude = 0.0
    
//    override class func primaryKey() -> String? {
//        "latitude"
//    }
    
    convenience init(latitude: Double, longitude: Double ) {
    self.init()
        self.latitude = latitude
        self.longitude = longitude
    }
}

