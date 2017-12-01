//
//  BLEListSceneCoordinator.swift
//  CleanArchitectureSample
//
//  Created by Tyler Casselman on 11/30/17.
//  Copyright © 2017 Tyler Casselman. All rights reserved.
//
protocol BLEListUI {}
protocol BLEDeviceManager {}
protocol BLEDeviceRepository {}
class BLEListSceneCoordinator {
    let ui: BLEListUI
    let deviceManager: BLEDeviceManager
    let deviceRepository: BLEDeviceRepository
    let state = BLEListState()
    init(ui: BLEListUI, bleDeviceManager: BLEDeviceManager, deviceRepository: BLEDeviceRepository) {
        self.ui = ui
        self.deviceManager = bleDeviceManager
        self.deviceRepository = deviceRepository
    }
}
