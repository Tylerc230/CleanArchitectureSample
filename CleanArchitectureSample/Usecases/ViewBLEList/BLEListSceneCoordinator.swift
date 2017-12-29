//
//  BLEListSceneCoordinator.swift
//  CleanArchitectureSample
//
//  Created by Tyler Casselman on 11/30/17.
//  Copyright © 2017 Tyler Casselman. All rights reserved.
//
import Foundation

protocol BLEListUI: class {
    func update(tableViewModel: BLEListState.TableViewModel, animateChangeSet: BLEListState.TableViewModel.RowChangeSet?)
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
        ui?.update(tableViewModel: BLEListState.TableViewModel(), animateChangeSet: nil)
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
        let (tableViewModel, changeSet) = state.append(bleDevices: [device])
        ui?.update(tableViewModel: tableViewModel, animateChangeSet: changeSet)
    }
}
