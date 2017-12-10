//
//  BLEListSceneCoordinator.swift
//  CleanArchitectureSample
//
//  Created by Tyler Casselman on 11/30/17.
//  Copyright © 2017 Tyler Casselman. All rights reserved.
//
import Foundation

protocol BLEListUI: class {
    func updateTable(animateChangeSet: BLEListState.TableModel.RowChangeSet?)
}

protocol BLEDeviceManagerObserver: class {
    func didDiscover(device: BLEDevice)
}

protocol BLEDeviceManager: class {
    weak var observer: BLEDeviceManagerObserver? { get set }
}

protocol BLEDeviceRepository {
    func fetchAllDevices() -> [DeviceEntry]
    func save(device: DeviceEntry)
}

protocol BLEListSceneCoordinatorDelegate: class {
    func discoveredDeviceSelected(_ discoveredDevice: BLEDevice)
    func knownDeviceSelected(_ knownDevice: DeviceEntry)
}

class BLEListSceneCoordinator {
    init(ui: BLEListUI, bleDeviceManager: BLEDeviceManager, deviceRepository: BLEDeviceRepository) {
        self.ui = ui
        self.deviceManager = bleDeviceManager
        self.deviceRepository = deviceRepository
        self.deviceManager.observer = self
        setInitialState()
    }
    
    weak var delegate: BLEListSceneCoordinatorDelegate?

    var tableModel: BLEListState.TableModel {
        return state.tableModel
    }
    
    func viewDidLoad() {
        ui?.updateTable(animateChangeSet: nil)
    }
    
    func indexPathSelected(_ indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let device = state.deviceEntry(at: indexPath.row)
            delegate?.knownDeviceSelected(device)
        default:
            let device = state.discoveredDevice(at: indexPath.row)
            delegate?.discoveredDeviceSelected(device)
        }
    }
    
    private func setInitialState() {
        _ = state.append(deviceEntries: deviceRepository.fetchAllDevices())
    }
    
    private weak var ui: BLEListUI?
    private let deviceManager: BLEDeviceManager
    private let deviceRepository: BLEDeviceRepository
    private var state = BLEListState()
}

extension BLEListSceneCoordinator: BLEDeviceManagerObserver {
    func didDiscover(device: BLEDevice) {
        let changeSet = state.append(discoveredBLEDevices: [device])
        ui?.updateTable(animateChangeSet: changeSet)
    }
}
