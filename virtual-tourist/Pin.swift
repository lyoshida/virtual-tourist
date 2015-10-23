//
//  Pin.swift
//  virtual-tourist
//
//  Created by Luis Yoshida on 10/23/15.
//  Copyright © 2015 Msen. All rights reserved.
//

import Foundation
import CoreData


@objc(Pin)
class Pin: NSManagedObject {
    
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        self.latitude = latitude as NSNumber
        self.longitude = longitude as NSNumber
    }

}