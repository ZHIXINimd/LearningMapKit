//
//  LocationService.swift
//  LearningMapKit
//
//  Created by Bruce Wang on 7/4/20.
//  Copyright © 2020 Bruce Wang. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationServiceDelegate: class {
    func authorisationDenied()
    func setMapRegion(center: CLLocation)
}

class LocationService: NSObject {
    var locationManager = CLLocationManager()
    
    weak var delegate: LocationServiceDelegate?
    
    override init(){
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func checkAuthorisaionStatus(){
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .denied:
            delegate?.authorisationDenied()
        case .authorizedAlways, .authorizedWhenInUse:
            break
        default:
            break
        }
    }
    
    
    private func startUpdatingLocation(){
        locationManager.startUpdatingLocation()
    }
}


extension LocationService: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkAuthorisaionStatus()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        if let location = locations.last{
            delegate?.setMapRegion(center: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
