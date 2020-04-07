//
//  ViewController.swift
//  LearningMapKit
//
//  Created by Bruce Wang on 7/4/20.
//  Copyright © 2020 Bruce Wang. All rights reserved.
//

import UIKit
import MapKit

class MapViewVC: UIViewController {
    
    @IBOutlet weak var mapView: MapView!
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchViewTopConstraint: NSLayoutConstraint!
    
    private let locationService = LocationService()
    
    private lazy var locationAlert: UIAlertController = {
        let alertController = UIAlertController(title: "Location Authorisation", message: "App can provide the points of interest based on your current location. To change the location please update your Privacy setting", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Location Authorisation", style: .default, handler: nil)
        let settingAction = UIAlertAction(title: "Update Setting", style: .default) { (_) in
            if let url = URL(string: UIApplication.openSettingsURLString){
                UIApplication.shared.open(url)
            }
            
        }
        
        alertController.addAction(okAction)
        alertController.addAction(settingAction)
        return alertController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationService.delegate = self
        controlView.layer.cornerRadius = 10.0
        searchView.layer.cornerRadius = 15.0
    }
    
    
    // MARK: - IBAction
    @IBAction func userLocationBtnTapped(_ sender: Any) {
        centerToUserLocation()
    }
    @IBAction func didTapMapBtn(_ sender: Any) {
        mapView.mapType = mapView.mapType == .standard ? .satellite :.standard
    }
    
    @IBAction func didTapSearchBtn(_ sender: Any) {
        SearchView(shown: true)
    }
    
    @IBAction func didTapCloseSearchViewBtn(_ sender: Any) {
        SearchView(shown: false)
    }
    
    @IBAction func didTapRestaurantBtn(_ sender: Any) {
    }
    
    @IBAction func didTapStarbucksBtn(_ sender: Any) {
    }
    // MARK: - Private Function
    private func centerToUserLocation(){
        let mapRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        
        DispatchQueue.main.async { [weak self] in
            self?.mapView.setRegion(mapRegion, animated: true)
        }
    }
    
    private func SearchView(shown: Bool){
        UIView.animate(withDuration: 0.3) {
            [weak self] in
            guard let weakSelf = self else {return}
            
            let viewHeight = weakSelf.searchView.frame.size.height
            
            weakSelf.searchViewTopConstraint.constant = shown ? -1*viewHeight : 0
            weakSelf.view.layoutIfNeeded()
        }
    }
}



extension MapViewVC: LocationServiceDelegate{
    func setMapRegion(center: CLLocation) {
        let mapRegion = MKCoordinateRegion(center: center.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        
        DispatchQueue.main.async {
            self.mapView.setRegion(mapRegion, animated: true)
        }
    }
    
    func authorisationDenied() {
        DispatchQueue.main.async {
            [weak self] in
            guard let weakSelf = self else {return}
            weakSelf.present(weakSelf.locationAlert, animated: true)
        }
    }
    
    
}
