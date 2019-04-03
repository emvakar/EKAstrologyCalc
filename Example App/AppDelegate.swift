//
//  AppDelegate.swift
//  Example App
//
//  Created by Emil Karimov on 27/03/2019.
//  Copyright © 2019 Emil Karimov. All rights reserved.
//

import UIKit
import AstrologyCalc

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = ViewController()
        self.window?.makeKeyAndVisible()
        
        let fd = Date()
        let sd = Date(timeIntervalSince1970: 1576800000)
        
        let fe = EclipseCalculator.getEclipseFor(date: fd, eclipseType: Eclipse.LUNAR, next: true)
        let se = EclipseCalculator.getEclipseFor(date: sd, eclipseType: Eclipse.LUNAR, next: true)
        
        let JD_JAN_1_1970_0000GMT = 2440587.5
        
        let fr = Date(timeIntervalSince1970: (fe.jd - JD_JAN_1_1970_0000GMT) * 86400)
        let sr = Date(timeIntervalSince1970: (se.jd - JD_JAN_1_1970_0000GMT) * 86400)
        
        print("Next eclipse from date \(fd) will be at: \(fr)")
        print("Next eclipse from date \(sd) will be at: \(sr)")
        return true
    }
    
}

extension AppDelegate {
    
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
