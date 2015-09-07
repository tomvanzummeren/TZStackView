
//
//  AppDelegate.swift
//  TZStackView-Example
//
//  Created by Tom van Zummeren on 20/06/15.
//  Copyright (c) 2015 Tom van Zummeren. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //Appearance proxy for the UISegmentedControl font
        UISegmentedControl.appearance().setTitleTextAttributes(
        [NSFontAttributeName:UIFont(name: "HelveticaNeue-Light", size:10.0)!],
                forState: UIControlState.Normal)

        //Launch the application
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
        return true
    }
}

