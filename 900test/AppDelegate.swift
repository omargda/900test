//
//  AppDelegate.swift
//  900test
//
//  Created by Omar Garcia De Alba on 10/26/16.
//  Copyright © 2016 Omar Garcia De Alba. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        NHSBroadcastManager.registerAppID("__test_app_id", withSecret: "Roophohro2kei2shiMe7", withCompletion: {
            application, error in
            
            if ((application != nil) && !(error != nil)) {
                print("Authentication succeeded")
                
                NHSApplication().login(withAuthorID: "0")
            } else {
                print("Auth Error: \(error)")
            }
        })
        
        
        
        /*
        [NHSBroadcastManager registerAppID:@"__test_app_id" withSecret:@"Roophohro2kei2shiMe7" withCompletion:^(NHSApplication *application, NSError *error) {
            if (application && !error) {
                NSLog(@"Authentication succeeded");
            } else {
                NSLog(@"Auth Error : %@", error);
            }
        }];
        
        [[NHSBroadcastManager sharedManager] scheduleSavedUploads];
        */
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        NHSBroadcastManager.shared().scheduleSavedUploads()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        //NHSBroadcastManager.shared().scheduleSavedUploads()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

