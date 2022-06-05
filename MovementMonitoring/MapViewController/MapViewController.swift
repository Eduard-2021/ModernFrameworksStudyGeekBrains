//
//  ViewController.swift
//  MovementMonitoring
//
//  Created by Eduard on 19.03.2022.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController {
    
    var mapAndLocationViewModel: MapAndLocationViewModel?
    
    var coordinate: CLLocationCoordinate2D?
    var marker: GMSMarker?
    var zoom: Float = 13
    var isFirstRun = true
    
    var route: GMSPolyline?
    
    @IBOutlet weak var mapView: GMSMapView!
    
//MARK: Сontrol buttons
    
    @IBAction func startTrack(_ sender: Any) {
        clearAndInitializationMap()
        mapAndLocationViewModel?.startTrackButtonDidTap()
    }
    
    @IBAction func stopTrack(_ sender: Any) {
        mapAndLocationViewModel?.stopTrackButtonDidTap()
    }

    @IBAction func showPreviousRoute(_ sender: Any) {
        mapAndLocationViewModel?.showPreviousRouteButtonDidTap(
            completionAlertController: { alertController in
                self.present(alertController, animated: true)
            },
            completionDidTapOk: { (routePathFromViewModel, commonViewFromViewModel) in
                guard let routePathFromViewModel = routePathFromViewModel, let commonViewFromViewModel = commonViewFromViewModel else {return}
                self.clearAndInitializationMap()
                self.route?.path = routePathFromViewModel
                self.mapView.animate(with: commonViewFromViewModel)
            })
    }
    
    //MARK: Main part with functions
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated:true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showMap()
        mapAndLocationViewModel = MapAndLocationViewModel(locationChanged: { [weak self] (routePath, position) in
            guard let self = self else {return}
            self.route?.path = routePath
            self.mapView.animate(to: position)
            if self.isFirstRun {
                self.isFirstRun = false
                self.addMarker()
            }
        })
    }

    private func clearAndInitializationMap(){
        // Отвязываем от карты старую линию
        route?.map = nil
        // Заменяем старую линию новой
        route = GMSPolyline()
        // Добавляем новую линию на карту
        route?.map = mapView
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
    }
}


