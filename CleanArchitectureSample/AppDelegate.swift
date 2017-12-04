//
//  AppDelegate.swift
//  CleanArchitectureSample
//
//  Created by Tyler Casselman on 11/20/17.
//  Copyright © 2017 Tyler Casselman. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let bleListView = BLEListViewController.instantiateFromStoryboard()
        let deviceManager = BLEDeviceManagerImpl()
        let deviceRepo = BLEDeviceRepositoryImpl()
        let sceneCoordinator = BLEListSceneCoordinator(ui: bleListView, bleDeviceManager: deviceManager, deviceRepository: deviceRepo)
        bleListView.sceneCoordinator = sceneCoordinator
        window?.rootViewController = bleListView
        return true
    }
}

