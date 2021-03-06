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
    @NSManaged var photos: [Photo]
    
    let sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext
    
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
        var coord: CLLocationCoordinate2D?
        
        self.sharedContext.performBlockAndWait() {
            coord = CLLocationCoordinate2D(latitude: self.latitude as Double, longitude: self.longitude as Double)
        }
        
        return coord!
    }
        
    func removePhotos() {
        for photo in self.photos {
            
            photo.deleteImageFromDisk()

            CoreDataStackManager.sharedInstance().managedObjectContext.deleteObject(photo)
            
        }
        
        self.sharedContext.performBlock() {
            do {
                try self.sharedContext.save()
            } catch let error as NSError {
                print(error)
            }
        }
    }
    
}