//
//  SearchService.swift
//  LearningMapKit
//
//  Created by Bruce Wang on 7/4/20.
//  Copyright © 2020 Bruce Wang. All rights reserved.
//

import MapKit

class SearchService{
    typealias SearchHandler = ([MKMapItem]) -> Void
    
    static func poiSearch(for poiType: POIType, around center: CLLocationCoordinate2D, completion:@escaping SearchHandler){
        let region = MKCoordinateRegion(center: center, latitudinalMeters: 1000, longitudinalMeters: 1000)
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = poiType.rawValue
        request.region = region
        
        MKLocalSearch(request: request).start { (response, error) in
            if error != nil{
                return
            }
            
            guard let response = response else {return}
            completion(response.mapItems)
        }
    }
}
