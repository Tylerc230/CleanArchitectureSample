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
        let (tableViewModel, rowAnimations) = state.updateDevices { changes in
            changes.add(entries: [device])
        }
        ui?.update(tableViewModel: tableViewModel, animateChangeSet: rowAnimations)
    }
    
    func didUpdate(device: DeviceEntry) {
        let (tableViewModel, rowAnimations) = state.updateDevices { changes in
            changes.modify(entries: [device])
        }
        ui?.update(tableViewModel: tableViewModel, animateChangeSet: rowAnimations)
    }
    
    func didRemove(device: DeviceEntry) {
        let (tableViewModel, rowAnimations) = state.updateDevices { changes in
            changes.remove(entries: [device])
        }
        ui?.update(tableViewModel: tableViewModel, animateChangeSet: rowAnimations)
    }
    
    private func setInitialState() {
        state.updateDevices { changes in
            changes.add(entries: deviceRepository.fetchAllDevices())
        }
    }
    
    private weak var ui: BLEListUI?
    private let deviceManager: BLEDeviceManager
    private let deviceRepository: BLEDeviceRepository
    private var state = BLEListState()
}

extension BLEListSceneCoordinator: BLEDeviceManagerObserver {
    func didDiscover(device: BLEDevice) {
        let (tableViewModel, changeSet) = state.updateDevices { state in
            state.bleDevices(movedInRange: [device])
        }
        ui?.update(tableViewModel: tableViewModel, animateChangeSet: changeSet)
    }
}
