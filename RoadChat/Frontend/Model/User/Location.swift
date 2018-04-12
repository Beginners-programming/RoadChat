//
//  Location.swift
//  RoadChat
//
//  Created by Niklas Sauer on 02.03.18.
//  Copyright © 2018 Niklas Sauer. All rights reserved.
//

import Foundation
import RoadChatKit
import CoreData
import CoreLocation

class Location: NSManagedObject {
    class func create(from prototype: RoadChatKit.Location.PublicLocation, in context: NSManagedObjectContext) throws -> Location {
        // create new location
        let location = Location(context: context)
        location.altitude = prototype.altitude
        location.course = prototype.course
        location.horizontalAccuracy = prototype.horizontalAccuracy
        location.verticalAccuracy = prototype.verticalAccuracy
        location.latitude = prototype.latitude
        location.longitude = prototype.longitude
        location.speed = prototype.speed
        location.timestamp = prototype.timestamp
        
        return location
    }
}

extension CLLocation {
    convenience init(location: Location) {
        let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        self.init(coordinate: coordinate, altitude: location.altitude, horizontalAccuracy: location.horizontalAccuracy, verticalAccuracy: location.verticalAccuracy, course: location.course, speed: location.speed, timestamp: location.timestamp!)
    }
}
