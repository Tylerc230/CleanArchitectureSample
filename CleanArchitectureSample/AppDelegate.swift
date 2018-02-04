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

    let window = UIWindow()
    let rootFlowCoordinator: BLEListFlowCoordinator
    override init() {
        let deviceManager = StubBLEDeviceManager()
        let devices = ["1", "A", "B"].map { DeviceEntry(identifier: UUID(), name: $0, type: "Type")}
        let deviceRepo = InMemoryBLEDeviceRepository(devices: devices)
        rootFlowCoordinator = BLEListFlowCoordinator(deviceManager: deviceManager, deviceRepository: deviceRepo)
        super.init()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//            creating a section and moving a row into the section animation looks bad (doesn't happen)
            deviceManager.discover(device: BLEDevice(identifier: devices.first!.identifier, type: "Type"))
            deviceManager.discover(device: BLEDevice(identifier: UUID(), type: "Type"))
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                deviceRepo.remove(deviceEntry: devices.first!)
                self.rootFlowCoordinator.didDelete(device: devices.first!)
            }
        }
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window.rootViewController = rootFlowCoordinator.rootViewController
        window.makeKeyAndVisible()
        return true
    }
}

