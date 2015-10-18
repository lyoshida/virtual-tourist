//
//  VTConstants.swift
//  virtual-tourist
//
//  Created by Luis Yoshida on 10/18/15.
//  Copyright © 2015 Msen. All rights reserved.
//

import Foundation


extension VTClient {
    
    struct Constants {
        
        /*
        https://api.flickr.com/services/rest/?
        method=flickr.photos.search&
        api_key=30ab42239a7dcaf5c78def7bc73958e2&
        bbox=-26.6724496945424,-48.7493398801136,-22.4724496945424,-44.5493398801136&
        format=json&
        nojsoncallback=1&
        extras=url_m
        */
        
        static let flickrApiKey: String = "30ab42239a7dcaf5c78def7bc73958e2"
        static let flickrUrl: String = "https://api.flickr.com/services/rest/"
        
    }
    
    struct ParameterKeys {
        static let apiKey: String = "api_key"
        static let method: String = "method"
        static let format: String = "format"
        static let bbox: String = "bbox"
        static let perPage: String = "per_page"
        static let extras: String = "extras"
    }
    
}