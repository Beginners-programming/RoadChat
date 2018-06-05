//
//  LocationViewController.swift
//  RoadChat
//
//  Created by Malcolm Malam on 11.04.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class LocationViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Typealiases
    typealias ColorPalette = BasicColorPalette
    
    // MARK: - Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locateButtonContainer: UIView!
    @IBOutlet weak var locateButton: UIButton!
    
    // MARK: - Private Properties
    private let viewFactory: ViewControllerFactory
    private let location: CLLocation
    private let colorPalette: ColorPalette
    
    private var trackingMode: MKUserTrackingMode = .none {
        didSet {
            mapView.userTrackingMode = trackingMode
            
            switch trackingMode {
            case .none:
                locateButton.setImage(#imageLiteral(resourceName: "location-arrow"), for: .normal)
            case .follow, .followWithHeading:
                locateButton.setImage(#imageLiteral(resourceName: "location-arrow-filled"), for: .normal)
            }
        }
    }
    
    // MARK: - Initialization
    init(viewFactory: ViewControllerFactory, location: CLLocation, colorPalette: ColorPalette) {
        self.location = location
        self.viewFactory = viewFactory
        self.colorPalette = colorPalette
    
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Customization
    override func viewDidLoad() {
        locateButtonContainer.backgroundColor = colorPalette.interfaceControlColor
        locateButton.backgroundColor = colorPalette.interfaceControlColor
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate

        mapView.setCenter(location.coordinate, animated: true)
        mapView.addAnnotation(annotation)

        let region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        mapView.setRegion(region, animated: true)
        trackingMode = .none
        mapView.showsUserLocation = true
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didDragMapView))
        panGestureRecognizer.delegate = self
        mapView.addGestureRecognizer(panGestureRecognizer)
    }
    
    // MARK: - Private Methods
    @IBAction func didPressLocateButton(_ sender: UIButton) {
        if mapView.isUserLocationVisible {
            trackingMode = trackingMode == .none ? .follow : .none
        } else {
            trackingMode = .none
            
            let userLocationAnnotation = MKMapPointForCoordinate(mapView.userLocation.coordinate)
            let senderLocationAnnotation = MKMapPointForCoordinate(location.coordinate)
            let userLocationPoint: MKMapRect = MKMapRectMake(userLocationAnnotation.x, userLocationAnnotation.y, 0, 0)
            let senderLocationPoint: MKMapRect = MKMapRectMake(senderLocationAnnotation.x, senderLocationAnnotation.y, 0, 0)
            
            let zoomRect: MKMapRect = MKMapRectUnion(userLocationPoint, senderLocationPoint)
            var region = MKCoordinateRegionForMapRect(zoomRect)
            region.span.latitudeDelta = 0.1
            region.span.longitudeDelta = 0.1
            
            mapView.setRegion(region, animated: true)
        }
    }
    
    @objc private func didDragMapView(panGestureRecognizer: UIPanGestureRecognizer) {
        guard panGestureRecognizer.state == .ended else {
            return
        }
        
        if trackingMode == .follow {
            trackingMode = .none
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
