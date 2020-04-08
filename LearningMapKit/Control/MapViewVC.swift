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
    @IBOutlet weak var searchTextField: UITextField!
    
    
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
    private var searchCompleter = MKLocalSearchCompleter()
    private var completerResults = [MKLocalSearchCompletion]()
    private var completerSearch = false
    
    // MARK:-  UIViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        locationService.delegate = self
        searchCompleter.delegate = self
        
        controlView.layer.cornerRadius = 10.0
        searchView.layer.cornerRadius = 15.0
        centerToUserLocation()
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
        poiType = nil
        SearchView(shown: true)
    }
    
    @IBAction func didTapCloseSearchViewBtn(_ sender: Any) {
        closeSlideView()
    }
    
    @IBAction func didTapRestaurantBtn(_ sender: Any) {
        completerSearch = false
        clearSearchTextField()
        poiType = .restaurant
        searchPOI()
    }
    
    @IBAction func didTapStarbucksBtn(_ sender: Any) {
        completerSearch = false
        clearSearchTextField()
        poiType = .starbucks
        searchPOI()
    }
    
    @IBAction func textFieldEditingChange(_ sender: UITextField) {
        poiType = .pin
        
        if let text = sender.text{
            searchCompleter.queryFragment = text
        }
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
        
        SearchService.search(for: poiType.rawValue, around: mapView.centerCoordinate) { [weak self] (mapItems) in
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
    
    
    private func clearSearchTextField(){
        searchTextField.text = nil
        searchTextField.resignFirstResponder()
    }
    
    private func closeSlideView(){
        clearSearchTextField()
        SearchView(shown: false)
    }
    
    private func highlight(text: String, rangeValues: [NSValue]) -> NSAttributedString{
        let attributes = [NSAttributedString.Key.backgroundColor: UIColor.yellow]
        let highlightedString = NSMutableAttributedString(string: text)
        
        let ranges = rangeValues.map{$0.rangeValue}
        ranges.forEach { (range) in
            highlightedString.addAttributes(attributes, range: range)
        }
        
        return highlightedString
    }
    
    
    private func centerMap(to poi: POI){
        setMapRegion(center: CLLocation(latitude: poi.coordinate.latitude, longitude: poi.coordinate.longitude))
        closeSlideView()
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
extension MapViewVC: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return completerSearch ? completerResults.count : pois.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellResult", for: indexPath)
        if completerSearch{
            let result = completerResults[indexPath.row]
            cell.textLabel?.attributedText = highlight(text: result.title, rangeValues: result.titleHighlightRanges)
            cell.detailTextLabel?.attributedText = highlight(text: result.subtitle, rangeValues: result.subtitleHighlightRanges)
        }else{
            let poi = pois[indexPath.row]
            
            cell.textLabel?.text = poi.subtitle
            cell.detailTextLabel?.text = poi.subtitle
            cell.detailTextLabel?.numberOfLines = 0
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if completerSearch{
            let searchResult = completerResults[indexPath.row]
            
            SearchService.search(for: searchResult.title) { [weak self] (mapItems) in
                guard let weakSelf = self else {return}
                
                weakSelf.updateSearchResult(with: mapItems)
                let poi = weakSelf.pois[0]
                weakSelf.centerMap(to: poi)
            }
        }else{
            let poi = pois[indexPath.row]
            mapView.addAnnotation(poi)
            centerMap(to: poi)
        }
        
        completerResults.removeAll()
        pois.removeAll()
    }
    
    
}


// MARK: - MKMapViewDelegate
extension MapViewVC: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if let poiType = poiType, poiType != .pin{
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

// MARK: - MKLocationSearchCompleterDelegate
extension MapViewVC: MKLocalSearchCompleterDelegate{
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completerSearch = true
        completerResults = completer.results
        tableView.reloadData()
    }
}


// MARK: - UITextFieldDelegate
extension MapViewVC: UITextFieldDelegate{
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - ScrollViewDelegate
extension MapViewVC: UIScrollViewDelegate{
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchTextField.resignFirstResponder()
    }
}
