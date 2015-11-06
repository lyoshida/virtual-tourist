//
//  Photos.swift
//  virtual-tourist
//
//  Created by Luis Yoshida on 10/20/15.
//  Copyright © 2015 Msen. All rights reserved.
//

import Foundation
import UIKit
import CoreData

@objc(Photo)
class Photo: NSManagedObject {

    @NSManaged var id: NSNumber
    @NSManaged var title: String
    @NSManaged var url_m: String
    @NSManaged var filePath: String
    @NSManaged var pin: Pin?
    
    let sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], pin: Pin, context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        

        title = dictionary["title"] as! String
        
        if let idString = dictionary["id"] as! String? {
            if let idInt = Int(idString) {
                self.id = NSNumber(integer: idInt)
            }
        }
        
        url_m = dictionary["url_m"] as! String
        
        self.pin = pin

        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        self.filePath = "\(paths)/\(self.id).jpg"
        
        self.saveFileToDisk()
    }
    
    func saveFileToDisk() {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            if let url = NSURL(string: self.url_m) {
                let image =  UIImage(data: NSData(contentsOfURL: url)!)
                UIImageJPEGRepresentation(image!, 100.0)?.writeToFile(self.filePath, atomically: true)
            }
        }
        
    }
    
    func deleteImageFromDisk() {
        
        print("preparing to remove file: \(self.filePath).")
        let fileManager = NSFileManager.defaultManager()
        if (fileManager.fileExistsAtPath(self.filePath)) {
            print("file found. removing...")
            do {
                print("removing file \(self.filePath)")
                try fileManager.removeItemAtPath(self.filePath)
            } catch _ {
                print("Error removing file.")
            }
        }
    }
    
    func deletePhoto() {
        deleteImageFromDisk()
        self.sharedContext.deleteObject(self)
    }
    
    func getImageFromDisk() -> UIImage? {
        
        let fileManager = NSFileManager.defaultManager()
    
        var image: UIImage = UIImage()
        
        if (fileManager.fileExistsAtPath(self.filePath)) {
            image =  UIImage(contentsOfFile: self.filePath)!
            return image
        } else {
            return nil
        }
        
    }
    
    func getImageFromURL() -> UIImage? {
        
        var image: UIImage = UIImage()

        if let url = NSURL(string: self.url_m) {
            image = UIImage(data: NSData(contentsOfURL: url)!)!
            return image
        }
        
        return nil
        
    }
    
}