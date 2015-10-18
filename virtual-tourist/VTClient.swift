//
//  VTClient.swift
//  virtual-tourist
//
//  Created by Luis Yoshida on 10/18/15.
//  Copyright © 2015 Msen. All rights reserved.
//

import Foundation


class VTClient: NSObject {
    
    var session: NSURLSession
    
    override init() {
        
        session = NSURLSession.sharedSession()
        super.init()
        
    }
    
    
    func taskForGETMethod(url: String, parameters: [String: AnyObject]?, headerParams: [String: String]?, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        // Build the URL
        var urlString : String
        if let params = parameters {
            urlString = "\(url)\(VTClient.escapedParameters(params))"
        } else {
            urlString = "\(url)"
        }
        
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        
        // Set header parameters to the request object
        if let headerParams = headerParams {
            for (key, value) in headerParams {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            if let error = downloadError {
                
                completionHandler(result: nil, error: error)
                
            } else {
                
                VTClient.parseJSONWithCompletionHandler(data!, removeStart: true, completionHandler: completionHandler)
                
            }
        }
        
        task.resume()
        
        return task
    }
    
    
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, removeStart: Bool, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var newData = data
        if removeStart {
            newData = data.subdataWithRange(NSMakeRange(5, data.length-5))
        }
        
        do {
            let parsedResult: AnyObject? = try NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments)
            completionHandler(result: parsedResult, error: nil)
        } catch let error as NSError {
            print("Error parsing JSON.")
            completionHandler(result: nil, error: error)
        }
        
    }
    
    class func sharedInstance() -> VTClient {
        
        struct Singleton {
            static var sharedInstance = VTClient()
        }
        
        return Singleton.sharedInstance
    }
    
}