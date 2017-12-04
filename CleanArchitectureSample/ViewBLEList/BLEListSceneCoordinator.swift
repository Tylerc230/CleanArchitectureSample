//
//  BLEListSceneCoordinator.swift
//  CleanArchitectureSample
//
//  Created by Tyler Casselman on 11/30/17.
//  Copyright © 2017 Tyler Casselman. All rights reserved.
//
protocol BLEListUI: class {
    func updateTable(animateChangeSet: BLEListState.TableModel.RowChangeSet?)
}
protocol BLEDeviceManager {}
protocol BLEDeviceRepository {
    func fetchAllDevices() -> [DeviceEntry]
}
class BLEListSceneCoordinator {
    init(ui: BLEListUI, bleDeviceManager: BLEDeviceManager, deviceRepository: BLEDeviceRepository) {
        self.ui = ui
        self.deviceManager = bleDeviceManager
        self.deviceRepository = deviceRepository
        setInitialState()
    }

    var tableModel: BLEListState.TableModel {
        return state.tableModel
    }
    
    func viewDidLoad() {
        ui?.updateTable(animateChangeSet: nil)
    }
    
    private func setInitialState() {
        _ = state.append(deviceEntries: deviceRepository.fetchAllDevices())
    }
    
    private weak var ui: BLEListUI?
    private let deviceManager: BLEDeviceManager
    private let deviceRepository: BLEDeviceRepository
    private var state = BLEListState()
}
