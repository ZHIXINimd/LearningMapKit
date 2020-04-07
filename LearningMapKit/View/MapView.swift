//
//  MapView.swift
//  LearningMapKit
//
//  Created by Bruce Wang on 7/4/20.
//  Copyright © 2020 Bruce Wang. All rights reserved.
//

import MapKit

class MapView: MKMapView{
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let compassView = subviews.filter({$0.isKind(of: NSClassFromString("MKCompassView")!)}).first{
            compassView.frame = CGRect(x: 16, y: 60, width: 40, height: 40)
        }
    }
}
