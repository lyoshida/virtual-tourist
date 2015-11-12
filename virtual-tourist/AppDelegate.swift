//
//  AppDelegate.swift
//  virtual-tourist
//
//  Created by Luis Yoshida on 10/11/15.
//  Copyright © 2015 Msen. All rights reserved.
//


// Project references:
// Specification: https://docs.google.com/document/d/1j-UIi1jJGuNWKoEjEk09wwYf4ebefnwcVrUYbiHh1MI/pub?embedded=true
// Grading rubric: https://docs.google.com/document/d/1ZY422V1_zq5rBGkGOlhLw_g99xS15Qx0tFUYtFOJ46Y/pub?embedded=true

// Refs
// Persistent Pins: http://www.juliusdanek.de/blog/coding/2015/07/14/persistent-pins-tutorial/
// Saving/Loading images: http://iostechsolutions.blogspot.com.br/2014/11/swift-save-and-load-image-from.html

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        self.saveSharedContext()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        self.saveSharedContext()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        self.saveSharedContext()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveSharedContext()
    }

    // MARK: - Core Data stack
    
    // Moved to a separate file (CoreDataStackManager.swift)

    func saveSharedContext() {
        self.sharedContext.performBlock() {
            do {
                try self.sharedContext.save()
            } catch let error as NSError {
                print("Error saving photo.")
                print(error)
            }
        }
    }
}

