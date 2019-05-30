//
//  AppDelegate.swift
//  TaskManager
//
//  Created by Nour  on 6/2/18.
//  Copyright © 2018 NourAraar. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        LocationHelper.shared.startUpdateLocation()
        AppConfig.setTabBarStyle()
        
        NotificationHelper.shared.initilizeNotification()
    
        let timer =   Timer.scheduledTimer(timeInterval: 5.0 * 60.0 * 60.0 , target: self, selector: #selector(getLocation), userInfo: nil, repeats: true)
        timer.fire()
        
        return true
    }
    
    @objc func getLocation(){
        
        guard let location = DataStore.shared.myLocation else {return}
        
        let sessionKey = DataStore.shared.currentSession?.SessionKey ?? "0"
        let company = DataStore.shared.currentCompany?.DB ?? "0"
        let ip = DataStore.shared.currentSession?.userIP ?? "0"
        let projectId = DataStore.shared.currentSession?.projectID ?? 0
        let date = Date()
        let mac = DataStore.shared.currentSession?.mac ?? "0"
        let lap = Lap()
        lap.SessionKey = sessionKey
        lap.mac = mac
        lap.lat  = location.latitiued
        lap.long = location.longtiued
        lap.projectID = projectId
        lap.company = company
        lap.startTime = date
        lap.synced = false
        lap.userIP = ip
        lap.userLocation = location
        var locations = DataStore.shared.locations
        locations.append(lap)
        DataStore.shared.locations = locations
        
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

