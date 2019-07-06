//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Mohamad El Araby on 4/16/19.
//  Copyright © 2019 Mohamad El Araby. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        DataController.shared.load()
        return true
    }

}

