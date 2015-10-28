//
//  PhotoAlbumViewController.swift
//  virtual-tourist
//
//  Created by Luis Yoshida on 10/20/15.
//  Copyright © 2015 Msen. All rights reserved.
//

import MapKit
import UIKit

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource  {
    
    var coordinates: CLLocationCoordinate2D?
    var photos: [Photo] = []
    
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        VTClient.sharedInstance().getPhotosInLocation(coordinates!) { result, error in
            if let error = error {
                print(error)
            } else {
                self.photos = result as! [Photo]
                
                self.photosCollectionView.reloadData()
            }
        }

    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = photosCollectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        if let url = NSURL(string: photos[indexPath.row].url_m) {
            if let data = NSData(contentsOfURL: url) {
                cell.imageView?.image = UIImage(data: data)
                
            }
        }
        
        return cell
    }
    
    
}