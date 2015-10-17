//
//  MapNavigationViewController.swift
//  virtual-tourist
//
//  Created by Luis Yoshida on 10/11/15.
//  Copyright © 2015 Msen. All rights reserved.
//

import UIKit
import MapKit

class MapNavigationViewController: UIViewController {

    @IBOutlet weak var deletePinView: UIView!
    @IBOutlet weak var navigationMapView: MKMapView!
    @IBOutlet weak var editPinsButton: UIBarButtonItem!
    
    var editMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.deletePinView.hidden = true
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

}

