//
//  MapAndLocationViewModel.swift
//  MovementMonitoring
//
//  Created by Eduard on 21.05.2022.
//

import UIKit
import GoogleMaps
import CoreLocation

protocol MapAndLocationViewModelOutput: AnyObject {
    var locationChanged: (GMSMutablePath, GMSCameraPosition) -> Void { get set }
}

protocol MapAndLocationViewModelInput: AnyObject {
    func startTrackButtonDidTap()
    func stopTrackButtonDidTap()
    func showPreviousRouteButtonDidTap(completionAlertController: @escaping (UIAlertController) -> Void, completionDidTapOk: @escaping (GMSMutablePath?, GMSCameraUpdate?) -> Void)

}

class MapAndLocationViewModel: MapAndLocationViewModelOutput {
    var coordinate: CLLocationCoordinate2D?
    var zoom: Float = 13
    var pathCoordinatesRealm = [PathCoordinatesRealm]()
    var coreLocationViewController: CoreLocationViewController?
    
    var routePath: GMSMutablePath?
    
    var locationChanged: (GMSMutablePath, GMSCameraPosition) -> Void
    
    init (locationChanged: @escaping (GMSMutablePath, GMSCameraPosition) -> Void) {
        self.locationChanged = locationChanged
        self.initAndClearRealm()
        coreLocationViewController = CoreLocationViewController()
        coreLocationViewController?.configureLocationManager()
        coreLocationViewController?.delegate = self
    }
    
    private func initAndClearRealm(){
        if let allSaveCoordinates = try? RealmService.load(typeOf: PathCoordinatesRealm.self) {
            try? RealmService.delete(object: allSaveCoordinates)
        }
    }
}

extension MapAndLocationViewModel: MapAndLocationViewModelInput {
    func startTrackButtonDidTap() {
        coreLocationViewController?.locationManager?.startMonitoringSignificantLocationChanges()
        routePath = GMSMutablePath()
        coreLocationViewController?.locationManager?.startUpdatingLocation()
    }
    
    func stopTrackButtonDidTap() {
        coreLocationViewController?.locationManager?.stopMonitoringSignificantLocationChanges()
        coreLocationViewController?.locationManager?.stopUpdatingLocation()
        var numberOfPointsToDelete = 0
        if let allSaveCoordinates = try? RealmService.load(typeOf: PathCoordinatesRealm.self) {
            numberOfPointsToDelete = allSaveCoordinates.count
            try? RealmService.delete(object: allSaveCoordinates)
            pathCoordinatesRealm.removeFirst(numberOfPointsToDelete)
        }
        try? RealmService.save(items: pathCoordinatesRealm)
    }
    
    
    func showPreviousRouteButtonDidTap(completionAlertController: @escaping (UIAlertController) -> Void, completionDidTapOk: @escaping (GMSMutablePath?, GMSCameraUpdate?) -> Void) {
        let alertController = UIAlertController(title: "Сейчас активно слежение!",
                                                message: "Нажмите Ок для его остановки и отображения предыдущего маршрута",
                                                preferredStyle: .alert)
        let buttonOk = UIAlertAction(title: "Ok", style: .default, handler:{ _ in
            let  pathAndCamera = self.loadAndShowPreviousTrack()
            completionDidTapOk(pathAndCamera.0, pathAndCamera.1)
        })
        alertController.addAction(buttonOk)
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        completionAlertController(alertController)
    }
    
    
    private func loadAndShowPreviousTrack() -> (GMSMutablePath?, GMSCameraUpdate?) {
        coreLocationViewController?.locationManager?.stopMonitoringSignificantLocationChanges()
        coreLocationViewController?.locationManager?.stopUpdatingLocation()
        var commonView: GMSCameraUpdate? = nil
        routePath = GMSMutablePath()
        if let previousSaveCoordinates = try? RealmService.load(typeOf: PathCoordinatesRealm.self) {
            
            for oneCoordinateInRealm in previousSaveCoordinates {
                let coordinate = CLLocationCoordinate2D(latitude: oneCoordinateInRealm.latitude, longitude: oneCoordinateInRealm.longitude)
                routePath?.add(coordinate)
            }
            
            if let firstCoordinateInRealm = previousSaveCoordinates.first,
               let lastCoordinateInRealm = previousSaveCoordinates.last {
                let firstCoordinate = CLLocationCoordinate2D(
                    latitude: firstCoordinateInRealm.latitude,
                    longitude: firstCoordinateInRealm.longitude)
                let lastCoordinate = CLLocationCoordinate2D(
                    latitude: lastCoordinateInRealm.latitude,
                    longitude: lastCoordinateInRealm.longitude)
         
                let bounds = GMSCoordinateBounds(
                    coordinate: firstCoordinate,
                    coordinate: lastCoordinate)
                commonView = GMSCameraUpdate.fit(bounds)
                
            }
        }
        return (routePath, commonView)
    }
    
    
    func locationManager(location: CLLocation){
        coordinate = location.coordinate
        guard let latitude = coordinate?.latitude, let longitude = coordinate?.longitude else {return}
        let singlePointCoordinates = PathCoordinatesRealm(latitude: latitude, longitude: longitude)
        pathCoordinatesRealm.append(singlePointCoordinates)
        
        // Добавляем новую координату в путь маршрута
        routePath?.add(location.coordinate)
        let position = GMSCameraPosition.camera(withTarget: location.coordinate,zoom: zoom)
        self.locationChanged(routePath!, position)
    }
}



