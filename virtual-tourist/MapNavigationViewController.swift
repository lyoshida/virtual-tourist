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
    var currentSelectedCoordinate: CLLocationCoordinate2D?
    
    var sharedContext: NSManagedObjectContext = CoreDataStackManager.sharedInstance().managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.deletePinView.hidden = true
        
        self.initializeGestureRecognizer()
        
        // Set the navigationMapView delegate as self.
        self.navigationMapView.delegate = self
        
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
            
            print(self.editMode)
        } else {
            self.deletePinView.hidden = true

            self.editMode = false
        }
        
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        if self.editMode == false {
            
            self.currentSelectedCoordinate = view.annotation?.coordinate
            performSegueWithIdentifier("showPhotos", sender: self)
            
        } else {
            
            let pin = view.annotation as! Pin
            sharedContext.deleteObject(pin)
            self.navigationMapView.removeAnnotation(view.annotation!)

            do {
                try self.sharedContext.save()
            } catch let error as NSError {
                print("Error removing pin.")
                print(error)
            }


        }
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showPhotos") {
            let photoAlbumView = segue.destinationViewController as! PhotoAlbumViewController
            photoAlbumView.coordinates = self.currentSelectedCoordinate
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
                
        let annotation = MKPointAnnotation()
        annotation.coordinate = touchMapCoordinate
        
        self.navigationMapView.addAnnotation(annotation)
        
        // Saves the Pin
        
        dispatch_async(dispatch_get_main_queue(), {
            
            let latitude: Double = Double(annotation.coordinate.latitude)
            let longitude: Double = Double(annotation.coordinate.longitude)
            _ = Pin(annotationLatitude: latitude, annotationLongitude: longitude, context: self.sharedContext)
            
            do {
                try self.sharedContext.save()
            } catch let error as NSError {
                print("Error saving pin.")
                print(error)
            }

        })
        
    }
    
    // Loads saved pins and add them to the map.
    func loadPins() {
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        do {
            let pins = try self.sharedContext.executeFetchRequest(fetchRequest) as! [Pin]
            
            for pin in pins {
//                let annotation = MKPointAnnotation()
//                annotation.coordinate = CLLocationCoordinate2DMake(Double(pin.latitude), Double(pin.longitude))
//                
                dispatch_async(dispatch_get_main_queue(), {
                    self.navigationMapView.addAnnotation(pin)
                })
            }
            
        } catch _ {
            print("Error fetching pins.")
        }
        
        
        
    }
    
}

