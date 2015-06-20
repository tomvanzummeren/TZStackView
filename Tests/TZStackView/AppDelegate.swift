//
//  AppDelegate.swift
//  TZStackView
//
//  Created by Tom van Zummeren on 10/06/15.
//  Copyright (c) 2015 Tom van Zummeren. All rights reserved.
//


import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject:AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)

        if #available(iOS 9.0, *) {
            window?.rootViewController = ViewController()
        } else {
            window?.rootViewController = UIViewController()
        }
        window?.makeKeyAndVisible()
        return true
    }
}
