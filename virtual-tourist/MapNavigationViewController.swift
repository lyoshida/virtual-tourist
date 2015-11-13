//
//  MapNavigationViewController.swift
//  virtual-tourist
//
//  Created by Luis Yoshida on 10/11/15.
//  Copyright © 2015 Msen. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapNavigationViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var deletePinView: UIView!
    @IBOutlet weak var navigationMapView: MKMapView!
    @IBOutlet weak var editPinsButton: UIBarButtonItem!
    
    var editMode: Bool = false
    var currentPin: Pin? = nil
    
    var sharedContext: NSManagedObjectContext = CoreDataStackManager.sharedInstance().managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.deletePinView.hidden = true
        self.editMode = false
        
        self.initializeGestureRecognizer()
        
        // Set the navigationMapView delegate as self.
        self.navigationMapView.delegate = self
        
        self.loadPins()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.deletePinView.hidden = true
        self.editMode = false
        
        self.loadPins()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func editPins(sender: UIBarButtonItem) {
        
        if self.editMode == false {
            UIView.animateWithDuration(1, animations: {
                self.deletePinView.hidden = false
            })
            
            self.editMode = true
            
        } else {
            self.deletePinView.hidden = true

            self.editMode = false
        }
        
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        print("selected pin")
        self.currentPin = view.annotation as? Pin
        
        if self.editMode == false {
            
            performSegueWithIdentifier("showPhotos", sender: self)
            
        } else {
            
            print("remove pin")
            self.currentPin?.removePhotos()
            self.navigationMapView.removeAnnotation(view.annotation!)
            self.sharedContext.deleteObject(self.currentPin!)

            do {
                try self.sharedContext.save()
                self.loadPins()
            } catch let error as NSError {
                print("Error removing pin.")
                print(error)
            }

        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showPhotos") {
            let photoAlbumView = segue.destinationViewController as! PhotoAlbumViewController
            photoAlbumView.pin = self.currentPin
            
            if self.currentPin == nil {
                print("no current pin")
            }
        }
    }
    
    
    func initializeGestureRecognizer() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("handleLongPress:"))
        longPressRecognizer.minimumPressDuration = 1.0
        navigationMapView.addGestureRecognizer(longPressRecognizer)
    }
    
    func handleLongPress(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state != .Began { return }
        
        let touchPoint = gestureRecognizer.locationInView(self.navigationMapView)
        let touchMapCoordinate = self.navigationMapView.convertPoint(touchPoint, toCoordinateFromView: navigationMapView)
        
        let annotation = Pin(annotationLatitude: touchMapCoordinate.latitude, annotationLongitude: touchMapCoordinate.longitude, context: sharedContext)
        
        self.navigationMapView.addAnnotation(annotation)
        
        
        do {
            try self.sharedContext.save()
        } catch let error as NSError {
            print("Error saving pin.")
            print(error)
        }
        
    }
    
    // Loads saved pins and add them to the map.
    func loadPins() {
        
        for annotation: MKAnnotation in self.navigationMapView.annotations {
            self.navigationMapView.removeAnnotation(annotation)
        }
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        do {
            let pins = try self.sharedContext.executeFetchRequest(fetchRequest) as! [Pin]
            
            for pin in pins {
                dispatch_async(dispatch_get_main_queue(), {
                    self.navigationMapView.addAnnotation(pin)
                })
            }
            
        } catch _ {
            print("Error fetching pins.")
        }
        
        
        
    }
    
}

