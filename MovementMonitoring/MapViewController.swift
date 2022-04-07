//
//  ViewController.swift
//  MovementMonitoring
//
//  Created by Eduard on 19.03.2022.
//

import UIKit
import GoogleMaps
import CoreLocation

class MapViewController: UIViewController {
    
    var coordinate: CLLocationCoordinate2D?
    var locationManager: CLLocationManager?
    var marker: GMSMarker?
    var zoom: Float = 17
    var isFirstRun = true
    
    @IBOutlet weak var mapView: GMSMapView!
    
    func configureLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.delegate = self
    }
    
    @IBAction func updateLocation(_ sender: Any) {
        locationManager?.startUpdatingLocation()
    }
    
    @IBAction func zoomIn(_ sender: Any) {
        zoom += 1
        showMap()
    }
    
    @IBAction func zoomOut(_ sender: Any) {
        zoom -= 1
        showMap()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocationManager()
        locationManager?.startUpdatingLocation()
    }
    
    func showMap() {
        guard let coordinate = coordinate else {return}
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: zoom)
        mapView.camera = camera
    }
    
    func addMarker() {
        guard let coordinate = coordinate else {return}
        let marker = GMSMarker(position: coordinate)
        marker.map = mapView
        self.marker = marker
    }
    
    func removeMarker() {
        marker?.map = nil
        marker = nil
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        if isFirstRun {
            isFirstRun = false
            locationManager?.stopUpdatingLocation()
        }
        coordinate = location.coordinate
        showMap()
        addMarker()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error:
        Error) {
        print(error)
    }
}
