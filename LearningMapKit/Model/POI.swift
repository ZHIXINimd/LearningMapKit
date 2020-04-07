//
//  POI.swift
//  LearningMapKit
//
//  Created by Bruce Wang on 7/4/20.
//  Copyright © 2020 Bruce Wang. All rights reserved.
//

import Foundation
import MapKit

enum POIType: String{
    case restaurant, starbucks
}

class POI: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let poiType: POIType
    
    init(title: String, address: String, coordinate: CLLocationCoordinate2D, poiType: POIType) {
        self.title = title
        self.subtitle = address
        self.coordinate = coordinate
        self.poiType = poiType
    }
}
