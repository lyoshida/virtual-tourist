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
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var newCollectionButton: UIToolbar!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    var sharedContext: NSManagedObjectContext = CoreDataStackManager.sharedInstance().managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.centerMapOnCoordinates(pin!)
        
        if pin!.photos.isEmpty {
            print("no local photos found. Requesting.")
            self.getPhotos()
        } else {
            print("local photos found.")
            dispatch_async(dispatch_get_main_queue(), {
                self.photosCollectionView.reloadData()
            })
            
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
            
        if let image = photo.getImageFromDisk() {
            print("reading image from disk")
            dispatch_async(dispatch_get_main_queue(), {
                print(image)
                cell.imageView.image = image
                cell.stopAnimate()
            })
        } else {
            print("getting images from URL")
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                let image = photo.getImageFromURL()
                print(image)
                dispatch_async(dispatch_get_main_queue(), {
                    cell.imageView.image = image
                    cell.stopAnimate()
                })
            })
        }
        
        
        return cell
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let collectionViewWidth = self.photosCollectionView.frame.width
        let photoWidth = Double(collectionViewWidth/3 - 1)
        return CGSize(width: photoWidth, height: photoWidth)
    }
    
    func centerMapOnCoordinates(pin: Pin) {

        self.mapView.addAnnotation(pin)
            
        let region = MKCoordinateRegionMakeWithDistance(pin.coordinate, 20000, 20000)
        self.mapView.setRegion(region, animated: true)
            
    }
    
    @IBAction func loadNewCollection(sender: UIBarButtonItem) {
        print("Retrieving new photos")
        self.pin!.photos = [Photo]()
        self.getPhotos()
        self.photosCollectionView.reloadData()
    }
    
    func getPhotos() {
        
        VTClient.sharedInstance().getPhotosInLocation(self.pin!) { result, error in
            if let error = error {
                print(error)
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.photosCollectionView.reloadData()
                })
                
            }
        }

    }
    
    
}