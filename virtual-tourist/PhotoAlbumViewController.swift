//
//  PhotoAlbumViewController.swift
//  virtual-tourist
//
//  Created by Luis Yoshida on 10/20/15.
//  Copyright © 2015 Msen. All rights reserved.
//

import MapKit
import CoreData
import UIKit

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    
    var pin: Pin?
    var photos: [Photo]?
    var page: Int = 1
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var newCollectionButton: UIToolbar!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    var sharedContext: NSManagedObjectContext = CoreDataStackManager.sharedInstance().managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.centerMapOnCoordinates(pin!)
        
        if pin!.photos.isEmpty {
            print("no local photos found. Requesting.")
            self.getPhotos(page)
            self.saveSharedContext()
        } else {
            print("local photos found.")
            self.photosCollectionView.reloadData()
            
        }
    
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.pin!.photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = photosCollectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        cell.animate()
        
        cell.imageView.contentMode = .ScaleAspectFill
        cell.contentMode = .ScaleAspectFill
    
        let photo = self.pin!.photos[indexPath.row] as Photo
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let image = photo.getImage()
            self.saveSharedContext()
            
            dispatch_async(dispatch_get_main_queue()) {
            
                cell.imageView.image = image
                cell.stopAnimate()
            }
        }
        
        return cell
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let collectionViewWidth = self.photosCollectionView.frame.width
        let photoWidth = Double(collectionViewWidth/3 - 1)
        return CGSize(width: photoWidth, height: photoWidth)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // The method deletePhoto calls another method that removes the images from the disk.
        self.pin!.photos[indexPath.row].deletePhoto()
        
        dispatch_async(dispatch_get_main_queue()) {
            self.photosCollectionView.reloadData()
        }
    }
    
    func centerMapOnCoordinates(pin: Pin) {

        self.mapView.addAnnotation(pin)
            
        let region = MKCoordinateRegionMakeWithDistance(pin.coordinate, 20000, 20000)
        self.mapView.setRegion(region, animated: true)
            
    }
    
    @IBAction func loadNewCollection(sender: UIBarButtonItem) {
        self.page += 1
        print("Retrieving new photos")
        self.pin!.removePhotos()
        self.getPhotos(self.page)
    }
    
    func getPhotos(page: Int) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            VTClient.sharedInstance().getPhotosInLocation(self.pin!, page: page) { result, error in
                if let error = error {
                    print(error)
                } else {
                    
                    self.saveSharedContext()
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.photosCollectionView.reloadData()
                    })
                    
                }
            }
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