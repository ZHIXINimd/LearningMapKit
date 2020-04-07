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
    
    @IBOutlet weak var mapView: MKMapView!
    
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
    }
    
    
    
    
}



extension MapViewVC: LocationServiceDelegate{
    func authorisationDenied() {
        DispatchQueue.main.async {
            [weak self] in
            guard let weakSelf = self else {return}
            weakSelf.present(weakSelf.locationAlert, animated: true)
        }
    }
    
    
}