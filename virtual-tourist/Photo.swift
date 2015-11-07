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
    @NSManaged var pin: Pin?
    
    var image: UIImage?
    
    var filePath: String {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        var path: String = ""
        
        self.sharedContext.performBlockAndWait() {
            path = "\(documentDirectory)/\(self.id).jpg"
        }
        
        return path
    }
    
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
        
    }
    
    func saveFileToDisk(image: UIImage) {

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            
            UIImageJPEGRepresentation(image, 100.0)?.writeToFile(self.filePath, atomically: true)
            
        }
        
    }
    
    func deleteImageFromDisk() {
        
        print("preparing to remove file: \(self.filePath).")
        let fileManager = NSFileManager.defaultManager()
        if self.fileExists() {
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
    
    /**
      Check if the image file is avaiable at self.filePath
    */
    func fileExists() -> Bool {
        
        var exists: Bool = false
        
        self.sharedContext.performBlockAndWait() {
            exists = NSFileManager.defaultManager().fileExistsAtPath(self.filePath)

        }
        
        return exists
    }
    
    /**
      Return the saved image if it's on the disk
    */
    func getImageFromDisk() -> UIImage? {
        
        var image: UIImage?
        
        self.sharedContext.performBlockAndWait() {
            if self.fileExists() {
                print("returning UIImage from disk")
                image = UIImage(contentsOfFile: self.filePath)
            }
        }
        
        return image
    }
    
    func getImageFromURL() -> UIImage? {
        
        var image: UIImage?
        var url: NSURL?

        self.sharedContext.performBlockAndWait() {
            url = NSURL(string: self.url_m)
        }
        
        image = UIImage(data: (NSData(contentsOfURL: url!)!))
        if !self.fileExists() {
            self.saveFileToDisk(image!)
            
        }
        
        return image

    }
    
    func getImage() -> UIImage? {
        
        print(self.filePath)
        
        if self.fileExists() {
            print("getImage: from disk")
            return self.getImageFromDisk()
        } else {
            print("getImage: from URL")
            return self.getImageFromURL()

        }
        
        
    }
    
    func saveSharedContext() {
        dispatch_async(dispatch_get_main_queue(), {
            do {
                try self.sharedContext.save()
            } catch let error as NSError {
                print("Error saving photo.")
                print(error)
            }
        })
    }
    
}