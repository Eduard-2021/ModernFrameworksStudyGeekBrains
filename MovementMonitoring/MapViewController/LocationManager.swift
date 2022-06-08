//
//  CoreLocationViewController.swift
//  MovementMonitoring
//
//  Created by Eduard on 23.05.2022.
//

import UIKit
import CoreLocation
import RxSwift
import RxCocoa

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let instance = LocationManager()
    
    private let lastLocation = PublishSubject<CLLocation>()
    var lastLocationObservable: Observable<CLLocation> {
        return lastLocation.asObserver()
    }
    
    var locationManager: CLLocationManager?
    
    private override init() {
        super.init()
        configureLocationManager()
    }
    
    func configureLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
        locationManager?.requestAlwaysAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        lastLocation.onNext(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error:
        Error) {
        print(error)
    } 
}
