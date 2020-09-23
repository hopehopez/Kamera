//
//  AppDelegate.swift
//  Kamera
//
//  Created by zsq on 2020/9/16.
//  Copyright © 2020 zsq. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        #if DEBUG
           Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle")?.load()
           // Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/macOSInjection10.bundle")?.load()
           // Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/tvOSInjection10.bundle")?.load()
           #endif
        return true
    }

    // MARK: UISceneSession Lifecycle

    

}

