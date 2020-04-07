//
//  MKPlacemark+Extension.swift
//  LearningMapKit
//
//  Created by Bruce Wang on 7/4/20.
//  Copyright © 2020 Bruce Wang. All rights reserved.
//

import MapKit

extension MKPlacemark{
    var formattedAddress: String?{
        guard
            let streetNumber = subThoroughfare,
            let streetName = thoroughfare,
            let city = locality,
            let state = administrativeArea,
            let zip = postalCode
        else {
            if let title = title{
                return "\(title)"
            }
            else{
                return nil
            }
        }
        
        let address = "\(streetNumber) \(streetName), \(city), \(state) \(zip)"
        return address
    }
}
