//
//  PhotoCollectionViewCell.swift
//  virtual-tourist
//
//  Created by Luis Yoshida on 10/28/15.
//  Copyright © 2015 Msen. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    func animate() {
        self.activityIndicatorView.startAnimating()
    }
    
    func stopAnimate() {
        self.activityIndicatorView.stopAnimating()
    }
    
}