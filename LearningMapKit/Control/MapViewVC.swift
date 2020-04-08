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
    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MapView!
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - Variables
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
    
    private var poiType: POIType?
    private var pois = [POI]()
    private var mapCenterLocation: CLLocation?
    
    // MARK:-  UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        locationService.delegate = self
        controlView.layer.cornerRadius = 10.0
        searchView.layer.cornerRadius = 15.0
        
        mapCenterLocation = CLLocation(latitude: mapView.userLocation.coordinate.latitude, longitude: mapView.userLocation.coordinate.longitude)
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
        poiType = .restaurant
        searchPOI()
    }
    
    @IBAction func didTapStarbucksBtn(_ sender: Any) {
        poiType = .starbucks
        searchPOI()
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
    
    private func searchPOI(){
        
        guard let poiType = poiType else {
            return
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible =  true
        
        SearchService.poiSearch(for: poiType, around: mapView.centerCoordinate) { [weak self] (mapItems) in
            self?.updateSearchResult(with: mapItems)
        }
        
    }
    
    private func updateSearchResult(with mapItems: [MKMapItem]){
        pois.removeAll()
        for mapItem in mapItems{
            if let name = mapItem.name, let address = mapItem.placemark.formattedAddress, let poiType = poiType{
                let poi = POI(title: name, address: address, coordinate: mapItem.placemark.coordinate, poiType: poiType)
                pois.append(poi)
            }
        }
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(pois)
        
        DispatchQueue.main.async {
            [weak self] in
            self?.tableView.reloadData()
        }
    }
}


// MARK: - LocatonServiceDelegate methods
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


// MARK: - TableViewDataSource and Delegate
extension MapViewVC: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pois.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellResult", for: indexPath)
        let poi = pois[indexPath.row]
        
        cell.textLabel?.text = poi.subtitle
        cell.detailTextLabel?.text = poi.subtitle
        cell.detailTextLabel?.numberOfLines = 0
        return cell
    }
    
    
}


// MARK: - MKMapViewDelegate
extension MapViewVC: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if let poiType = poiType{
            let newCenterLocation = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
            if let prevMapCenterLocation = mapCenterLocation{
                if newCenterLocation.distance(from: prevMapCenterLocation) > 500
                {
                    mapCenterLocation = newCenterLocation
                    searchPOI()
                }
                
            }
        }
    }
}
