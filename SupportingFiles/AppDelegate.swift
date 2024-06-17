//
//  AppDelegate.swift
//  ImageSearch
//
//  Created by Екатерина Токарева on 11/02/2023.
//

import UIKit
import netfox

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        NFX.sharedInstance().start()
        return true
    }
}

