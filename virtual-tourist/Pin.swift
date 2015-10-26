//
//  Pin.swift
//  virtual-tourist
//
//  Created by Luis Yoshida on 10/23/15.
//  Copyright © 2015 Msen. All rights reserved.
//

import Foundation
import CoreData
import MapKit


@objc(Pin)
class Pin: NSManagedObject, MKAnnotation {
    
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(annotationLatitude: Double, annotationLongitude: Double, context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        self.latitude = annotationLatitude as NSNumber
        self.longitude = annotationLongitude as NSNumber
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude as Double, longitude: longitude as Double)
    }

}