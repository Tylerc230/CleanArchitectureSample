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
        sceneCoordinator.delegate = self
    }
    
    var rootViewController: UIViewController {
        return nav
    }
    
    private func name(discoveredDevice: BLEDevice) {
        
    }
    
    private func update(knownDevice: DeviceEntry) {
        
    }
}

extension BLEListFlowCoordinator: BLEListSceneCoordinatorDelegate {
    func knownDeviceSelected(_ knownDevice: DeviceEntry) {
        update(knownDevice: knownDevice)
    }
    
    func discoveredDeviceSelected(_ discoveredDevice: BLEDevice) {
        name(discoveredDevice: discoveredDevice)
    }
    
}
