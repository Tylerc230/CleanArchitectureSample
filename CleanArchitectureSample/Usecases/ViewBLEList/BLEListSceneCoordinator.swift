//
//  BLEListSceneCoordinator.swift
//  CleanArchitectureSample
//
//  Created by Tyler Casselman on 11/30/17.
//  Copyright © 2017 Tyler Casselman. All rights reserved.
//
import Foundation

protocol BLEListUI: class {
    func update(tableViewModel: BLEListState.TableViewModel, animateChangeSet: RowAnimations?)
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

    func viewDidLoad() {
        ui?.update(tableViewModel: state.tableViewModel, animateChangeSet: nil)
    }
    
    func indexPathSelected(_ indexPath: IndexPath) {
        let transition = state.didSelectRow(at: indexPath)
        switch transition {
        case .newDeviceEntry(let bleDevice):
            delegate?.discoveredDeviceSelected(bleDevice)
        case .updateDeviceEntry(let deviceEntry):
            delegate?.knownDeviceSelected(deviceEntry)
            
        }
    }
    
    func didCreate(device: DeviceEntry) {
        let (tableViewModel, changeSet) = state.updateDevices { state in
            state.append(deviceEntries: [device])
        }
        ui?.update(tableViewModel: tableViewModel, animateChangeSet: changeSet)
    }
    
    func didUpdate(device: DeviceEntry) {
        let (tableViewModel, changeSet) = state.updateDevices { state in
            state.update(deviceEntries: [device])
        }
        ui?.update(tableViewModel: tableViewModel, animateChangeSet: changeSet)
    }
    
    func didRemove(device: DeviceEntry) {
        let (tableViewModel, changeSet) = state.updateDevices { state in
            state.remove(deviceEntries: [device])
        }
        ui?.update(tableViewModel: tableViewModel, animateChangeSet: changeSet)
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
        let (tableViewModel, changeSet) = state.updateDevices { state in
            state.append(bleDevices: [device])
        }
        ui?.update(tableViewModel: tableViewModel, animateChangeSet: changeSet)
    }
}
