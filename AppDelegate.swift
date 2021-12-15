//
//  AppDelegate.swift
//  CLPlayer
//
//  Created by Chen JmoVxia on 2021/10/26.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window?.rootViewController = CLTabBarController()
        window?.makeKeyAndVisible()
        return true
    }
}

extension AppDelegate {
    func application(_: UIApplication, supportedInterfaceOrientationsFor _: UIWindow?) -> UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
}
