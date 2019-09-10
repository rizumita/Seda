//
//  AppDelegate.swift
//  SedaUIKitSampleApp
//
//  Created by 和泉田 領一 on 2019/09/10.
//

import UIKit
import Seda

let store = LegacyStore(reducer: appReducer(), state: AppState())

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

}

