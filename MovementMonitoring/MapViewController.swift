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
    var zoom: Float = 13
    var isFirstRun = true
    
    var route: GMSPolyline?
    var routePath: GMSMutablePath?
    
    var pathCoordinatesRealm = [PathCoordinatesRealm]()
    
    
    @IBOutlet weak var mapView: GMSMapView!
    
//MARK: Сontrol buttons
    
    @IBAction func startTrack(_ sender: Any) {
        locationManager?.startMonitoringSignificantLocationChanges()
        clearAndInitializationMap()
        // Запускаем отслеживание или продолжаем, если оно уже запущено
        locationManager?.startUpdatingLocation()
    }
    
    @IBAction func stopTrack(_ sender: Any) {
        locationManager?.stopMonitoringSignificantLocationChanges()
        locationManager?.stopUpdatingLocation()
        var numberOfPointsToDelete = 0
        if let allSaveCoordinates = try? RealmService.load(typeOf: PathCoordinatesRealm.self) {
            numberOfPointsToDelete = allSaveCoordinates.count
            try? RealmService.delete(object: allSaveCoordinates)
            pathCoordinatesRealm.removeFirst(numberOfPointsToDelete)
        }
        try? RealmService.save(items: pathCoordinatesRealm)
    }

    @IBAction func showPreviousRoute(_ sender: Any) {
        stopMonitoringLocationChangesNotification{
            self.loadAndShowPreviousTrack()
        }
    }
    
    //MARK: Main part with functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocationManager()
    }
    
    private func configureLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
        locationManager?.requestAlwaysAuthorization()
    }
    
    private func clearAndInitializationMap(){
        // Отвязываем от карты старую линию
        route?.map = nil
        // Заменяем старую линию новой
        route = GMSPolyline()
        // Заменяем старый путь новым, пока пустым (без точек)
        routePath = GMSMutablePath()
        // Добавляем новую линию на карту
        route?.map = mapView
    }
    
    private func loadAndShowPreviousTrack(){
        locationManager?.stopMonitoringSignificantLocationChanges()
        locationManager?.stopUpdatingLocation()
        clearAndInitializationMap()

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
         
                route?.path = routePath
                coordinateBounds(
                    first: firstCoordinate,
                    last: lastCoordinate)
            }
        }
    }
    
    //Уставнока фокуса на карте таким образом, чтобы был виден весь маршрут
    func coordinateBounds(first: CLLocationCoordinate2D, last: CLLocationCoordinate2D){
        let bounds = GMSCoordinateBounds(coordinate: first, coordinate: last)
        let commonView = GMSCameraUpdate.fit(bounds)
        mapView.animate(with: commonView)
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

}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        coordinate = location.coordinate
        guard let latitude = coordinate?.latitude, let longitude = coordinate?.longitude else {return}
        
        if isFirstRun {
            isFirstRun = false
            showMap()
            addMarker()
        }
        
        let singlePointCoordinates = PathCoordinatesRealm(latitude: latitude, longitude: longitude)
        pathCoordinatesRealm.append(singlePointCoordinates)
        
        // Добавляем новую координату в путь маршрута
        routePath?.add(location.coordinate)
        // Обновляем путь у линии маршрута путём повторного присвоения
        route?.path = routePath
        // Чтобы наблюдать за движением, установим камеру на только что добавленную
        // точку
        
        let position = GMSCameraPosition.camera(withTarget: location.coordinate,
        zoom: zoom)
        mapView.animate(to: position)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error:
        Error) {
        print(error)
    }
}


extension MapViewController {

    func stopMonitoringLocationChangesNotification(completion: @escaping () -> Void) {
        let alertController = UIAlertController(title: "Сейчас активно слежение!",
                                                message: "Нажмите Ок для его остановки и отображения предыдущего маршрута",
                                                preferredStyle: .alert)
        let buttonOk = UIAlertAction(title: "Ok", style: .default, handler:{ _ in
            completion()
        })
        alertController.addAction(buttonOk)
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
}
