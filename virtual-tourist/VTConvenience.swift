//
//  VTConvenience.swift
//  virtual-tourist
//
//  Created by Luis Yoshida on 10/18/15.
//  Copyright © 2015 Msen. All rights reserved.
//

import Foundation
import MapKit

extension VTClient {
    
    func getPhotosInLocation(locationCoordinates: CLLocationCoordinate2D, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> Void {
        
        let params: [String: String] = [
            VTClient.ParameterKeys.method: VTClient.ApiMethods.photoSearch.rawValue,
            VTClient.ParameterKeys.apiKey: VTClient.Constants.flickrApiKey,
            VTClient.ParameterKeys.format: "json",
            VTClient.ParameterKeys.bbox: createBoundingBoxString(locationCoordinates),
            VTClient.ParameterKeys.extras: "url_m",
            VTClient.ParameterKeys.perPage: "20",
            VTClient.ParameterKeys.noJsonCallback: "1"
        ]
        
        taskForGETMethod(VTClient.Constants.flickrUrl, parameters: params) { result, error in
            if let error = error {
                completionHandler(result: nil, error: error)
                print("Error retriving photos.")
            } else {
                
                var photoList: [Photo] = []
                
                if let photos = result.valueForKey("photos") as! [String: AnyObject]? {
                    if let photo = photos["photo"] as! [AnyObject]? {
                        for p in photo {
                            let photoJson = p as! [String: AnyObject]
                            photoList.append(Photo(dictionary: photoJson, context: self.sharedContext))
                        }
                    }
                }
                
                completionHandler(result: photoList, error: nil)
            }
        }
        
    }
    
    
    func createBoundingBoxString(locationCoordinates: CLLocationCoordinate2D) -> String {
        
        let latitude = locationCoordinates.latitude
        let longitude = locationCoordinates.longitude
        
        let BOUNDING_BOX_HALF_WIDTH = 1.0
        let BOUNDING_BOX_HALF_HEIGHT = 1.0
        let LAT_MIN = -90.0
        let LAT_MAX = 90.0
        let LON_MIN = -180.0
        let LON_MAX = 180.0
        
        /* Fix added to ensure box is bounded by minimum and maximums */
        let bottom_left_lon = max(longitude - BOUNDING_BOX_HALF_WIDTH, LON_MIN)
        let bottom_left_lat = max(latitude - BOUNDING_BOX_HALF_HEIGHT, LAT_MIN)
        let top_right_lon = min(longitude + BOUNDING_BOX_HALF_HEIGHT, LON_MAX)
        let top_right_lat = min(latitude + BOUNDING_BOX_HALF_HEIGHT, LAT_MAX)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    
}