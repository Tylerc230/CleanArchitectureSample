//
//  BLEListFlowCoordinator.swift
//  CleanArchitectureSample
//
//  Created by Tyler Casselman on 12/4/17.
//  Copyright © 2017 Tyler Casselman. All rights reserved.
//

import UIKit
class BLEListFlowCoordinator {
    let nav: UINavigationController
    private let deviceManager: BLEDeviceManager
    private let deviceRepository: BLEDeviceRepository
    private let bleListScene: BLEListSceneCoordinator
    init(deviceManager: BLEDeviceManager, deviceRepository: BLEDeviceRepository) {
        self.deviceManager = deviceManager
        self.deviceRepository = deviceRepository
        let bleListView = BLEListViewController.instantiateFromStoryboard()
        nav = UINavigationController(rootViewController: bleListView)
        bleListScene = BLEListSceneCoordinator(ui: bleListView, bleDeviceManager: deviceManager, deviceRepository: deviceRepository)
        bleListView.sceneCoordinator = bleListScene
        bleListScene.delegate = self
    }
    
    var rootViewController: UIViewController {
        return nav
    }
    
    private func name(discoveredDevice: BLEDevice) {
        let ui = showEditView()
        let sceneCoordinator = BLEEditSceneCoordinator(forNewDevice: discoveredDevice, ui: ui, deviceRepository: deviceRepository)
        sceneCoordinator.delegate = self
        ui.sceneCoordinator = sceneCoordinator
    }
    
    private func update(knownDevice: DeviceEntry) {
        let ui = showEditView()
        let sceneCoordinator = BLEEditSceneCoordinator(forExistingEntry: knownDevice, ui: ui, deviceRepository: deviceRepository)
        sceneCoordinator.delegate = self
        ui.sceneCoordinator = sceneCoordinator
    }
    
    private func showEditView() -> BLEEditViewController {
        let editView = BLEEditViewController.instatiateFromStoryboard()
        nav.pushViewController(editView, animated: true)
        return editView
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

extension  BLEListFlowCoordinator: BLEEditSceneDelegate {
    func didCreate(device: DeviceEntry) {
        nav.pop(animated: true) { [weak self] in
            self?.bleListScene.didCreate(device: device)
        }
        
    }
    
    func didUpdate(device: DeviceEntry) {
        nav.pop(animated: true) { [weak self] in
            self?.bleListScene.didUpdate(device: device)
        }
    }

    func didCancel() {
        nav.popViewController(animated: true)
    }
}
