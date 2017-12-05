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
    let rootFlowCoordinator: BLEListFlowCoordinator
    override init() {
        let deviceManager = StubBLEDeviceManager()
        let deviceRepo = StubDeviceRepository()
        rootFlowCoordinator = BLEListFlowCoordinator(deviceManager: deviceManager, deviceRepository: deviceRepo)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            deviceManager.discover(device: BLEDevice(identifier: UUID(), type: "Fake device"))
        }
        super.init()
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window?.rootViewController = rootFlowCoordinator.rootViewController
        return true
    }
}

