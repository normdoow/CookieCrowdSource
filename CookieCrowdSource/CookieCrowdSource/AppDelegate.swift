//
//  AppDelegate.swift
//  CookieCrowdSource
//
//  Created by Noah Bragg on 8/19/17.
//  Copyright © 2017 Noah Bragg. All rights reserved.
//

import UIKit
import Stripe
import PusherSwift
import UserNotifications
import KYDrawerController
import Mixpanel

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var pusher: Pusher!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        STPPaymentConfiguration.shared().publishableKey = "pk_test_tAMChOZmT4OHrVNyhGvJmuLH"
        // Override point for customization after application launch.
        
        //mixpanel init
        
        //setup for Pusher notifications
        let options = PusherClientOptions(
            host: .cluster("us2")
        )
        pusher = Pusher(key: "d05669f4df7a1f96f929", options: options)
        
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                // Handle user allowing / declining notification permission. Example:
                if (granted) {
                    DispatchQueue.main.async(execute: {
                        application.registerForRemoteNotifications()
                    })
                } else {
                    print("User declined notification permissions")
                }
            }
        } else {
            // Fallback on earlier versions
            let notificationSettings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            application.registerUserNotificationSettings(notificationSettings)
            application.registerForRemoteNotifications()
        }
        
        
        //setup the drawer
//        let mainViewController   = ViewController()
//        let drawerViewController = DrawerController()
//        let drawerController     = KYDrawerController(drawerDirection: .left, drawerWidth: 300)
//        drawerController.mainViewController = UINavigationController(
//            rootViewController: mainViewController
//        )
//        drawerController.drawerViewController = drawerViewController
//
//        /* Customize
//         drawerController.drawerDirection = .Right
//         drawerController.drawerWidth     = 200
//         */
//
//        window = UIWindow(frame: UIScreen.main.bounds)
//        window?.rootViewController = drawerController
//        window?.makeKeyAndVisible()
        
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken : Data) {
        pusher.nativePusher.register(deviceToken: deviceToken)
        pusher.nativePusher.subscribe(interestName: "cook_available")
        Mixpanel.mainInstance().identify(distinctId: UIDevice.current.identifierForVendor!.uuidString)
        Mixpanel.mainInstance().people.addPushDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print("i am not available in simulator \(error)")
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

