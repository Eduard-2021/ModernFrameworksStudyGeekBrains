//
//  CoreLocationViewController.swift
//  MovementMonitoring
//
//  Created by Eduard on 23.05.2022.
//

import UIKit
import CoreLocation

class CoreLocationViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager?
    var delegate: MapAndLocationViewModel?
    
    func configureLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
        locationManager?.requestAlwaysAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        delegate?.locationManager(location: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error:
        Error) {
        print(error)
    } 
}
