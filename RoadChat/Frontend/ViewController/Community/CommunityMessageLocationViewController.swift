//
//  communityMessageLocationViewController.swift
//  RoadChat
//
//  Created by Malcolm Malam on 11.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class CommunityMessageLocationViewController: UIViewController, MKMapViewDelegate {

    private let location: CLLocation
    private let viewFactory: ViewControllerFactory
    
    init(viewFactory: ViewControllerFactory, location: CLLocation){
        self.location = location
        self.viewFactory = viewFactory
        
        let mapView = MKMapView(frame: view.frame)
        
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.vtopAnchor.constraint(equalTo: view.topAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
        
    }
    
    override func viewDidLoad() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        
        mapView.setCenter(location.coordinate, animated: true)
        mapView.addAnnotations(annotation)
    }
    

}
