//
//  Photos.swift
//  virtual-tourist
//
//  Created by Luis Yoshida on 10/20/15.
//  Copyright © 2015 Msen. All rights reserved.
//

import Foundation
import CoreData

@objc(Photo)
class Photo: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var title: String
    @NSManaged var url_m: String
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Photos", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        

        title = dictionary["title"] as! String
        
        if let idString = dictionary["id"] as! String? {
            if let idInt = Int(idString) {
                self.id = NSNumber(integer: idInt)
            }
        }
        
        url_m = dictionary["url_m"] as! String
    }
    
}