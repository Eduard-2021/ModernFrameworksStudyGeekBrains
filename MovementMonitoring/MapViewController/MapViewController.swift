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
    
    var markerImage: UIImage?
    let profileMarkerSize : CGFloat = 40
    
    lazy var profileMarkerImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = profileMarkerSize*0.8/2
        iv.layer.masksToBounds = true
        return iv
    }()
    
    lazy var backgroundMarkerImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
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
        changeTokenRequest()
        showMap()
        mapAndLocationViewModel = MapAndLocationViewModel(locationChanged: { [weak self] (routePath, position, coordinate) in
            guard let self = self else {return}
            self.coordinate = coordinate
            self.route?.path = routePath
            self.mapView.animate(to: position)
            self.addMarker()
        })
    }
    
    
    func changeTokenRequest(){
        let alertController = UIAlertController(title: "Хотите ли Вы добавить в маркер карты изображение из коллекции фотографий телефона?",
                                                message: "",
                                                preferredStyle: .alert)
        let buttonYes = UIAlertAction(title: "Да", style: .cancel)
                                        { _ in self.getImageFromLibrary()}
        let buttonNo = UIAlertAction(title: "Нет", style: .default)
                                        { _ in}
        alertController.addAction(buttonYes)
        alertController.addAction(buttonNo)
        present(alertController, animated: true)

    }
    
    private func getImageFromLibrary() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }

    private func clearAndInitializationMap(){
        route?.map = nil
        route = GMSPolyline()
        route?.map = mapView
    }
    
    func showMap() {
        guard let coordinate = coordinate else {return}
        let camera = GMSCameraPosition.camera(withTarget: coordinate, zoom: zoom)
        mapView.camera = camera
    }
    
    func addMarker() {
        guard let coordinate = coordinate else {return}
        deleteMarker()
        let marker = GMSMarker(position: coordinate)
        if let markerImage = markerImage {
            let profileMarkerView = UIView(frame: CGRect(x: 0, y: 0, width: profileMarkerSize, height: profileMarkerSize * 2))
            backgroundMarkerImageView.image = UIImage(named: "marker")
            profileMarkerView.addSubview(backgroundMarkerImageView)
            constrainBackgroundMarkerImageView(superView: profileMarkerView)
            profileMarkerImageView.image = markerImage
            backgroundMarkerImageView.addSubview(profileMarkerImageView)
            constrainProfileMarkerImageView(superView: backgroundMarkerImageView)
            marker.iconView = profileMarkerView
        }
        marker.map = mapView
        self.marker = marker
    }
    
    func constrainBackgroundMarkerImageView(superView: UIView) {
        backgroundMarkerImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundMarkerImageView.widthAnchor.constraint(equalTo:  superView.widthAnchor),
            backgroundMarkerImageView.heightAnchor.constraint(equalTo: superView.heightAnchor),
            ])
    }
    
    func constrainProfileMarkerImageView(superView: UIView) {
        profileMarkerImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileMarkerImageView.topAnchor.constraint(equalTo: superView.topAnchor, constant: profileMarkerSize/3),
            profileMarkerImageView.leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: profileMarkerSize/10),
            profileMarkerImageView.widthAnchor.constraint(equalToConstant: profileMarkerSize*0.8),
            profileMarkerImageView.heightAnchor.constraint(equalToConstant: profileMarkerSize*0.8),
            ])
    }
    
    func deleteMarker() {
        guard let marker = marker else {return}
        marker.map = nil
    }
}


extension MapViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {return}
        markerImage = image
        if let markerImage = markerImage {
            mapAndLocationViewModel?.saveImageToDisk(imageName: "ImageForMarker", image: markerImage)
        }
        picker.dismiss(animated: true)
    }

}
