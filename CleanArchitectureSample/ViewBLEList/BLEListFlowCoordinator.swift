//
//  BLEListFlowCoordinator.swift
//  CleanArchitectureSample
//
//  Created by Tyler Casselman on 12/4/17.
//  Copyright © 2017 Tyler Casselman. All rights reserved.
//

import UIKit
class BLEListFlowCoordinator {
    private let nav: UINavigationController
    private let deviceManager: BLEDeviceManager
    private let deviceRepository: BLEDeviceRepository
    init(deviceManager: BLEDeviceManager, deviceRepository: BLEDeviceRepository) {
        self.deviceManager = deviceManager
        self.deviceRepository = deviceRepository
        let bleListView = BLEListViewController.instantiateFromStoryboard()
        nav = UINavigationController(rootViewController: bleListView)
        let sceneCoordinator = BLEListSceneCoordinator(ui: bleListView, bleDeviceManager: deviceManager, deviceRepository: deviceRepository)
        bleListView.sceneCoordinator = sceneCoordinator
    }
    
    var rootViewController: UIViewController {
        return nav
    }
}
