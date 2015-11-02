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
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var newCollectionButton: UIToolbar!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    var sharedContext: NSManagedObjectContext = CoreDataStackManager.sharedInstance().managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.centerMapOnCoordinates(pin!)
        
        if pin!.photos == [] {
            self.getPhotos()
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
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            
            if let data = NSData(contentsOfFile: self.pin!.photos[indexPath.row].filePath) {
                dispatch_async(dispatch_get_main_queue(), {
                    cell.imageView.image = UIImage(data: data)
                })
            }
            
//            if let url = NSURL(string: self.photos[indexPath.row].url_m) {
//                if let data = NSData(contentsOfURL: url) {
//                    dispatch_async(dispatch_get_main_queue(), {
//                        
//                        cell.imageView?.image = UIImage(data: data)
//                        
//                        cell.stopAnimate()
//                    })
//                    
//                }
//            }
        })
        
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
        
        self.photosCollectionView.reloadData()
        self.getPhotos()
        
    }
    
    func getPhotos() {
        
        VTClient.sharedInstance().getPhotosInLocation(pin!.coordinate) { result, error in
            if let error = error {
                print(error)
            } else {
                
                if let photos = result as? [Photo] {
                    for photo in photos {
                        photo.pin = self.pin
                        self.pin!.photos.append(photo)
                    }
                }
                
                do {
                    try self.sharedContext.save()
                } catch let error as NSError {
                    print("Error removing pin.")
                    print(error)
                }

                dispatch_async(dispatch_get_main_queue(), {
                    self.photosCollectionView.reloadData()
                })
                
            }
        }

    }
    
    
}