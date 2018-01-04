//
//  BLEEditSceneCoordinator.swift
//  CleanArchitectureSample
//
//  Created by Tyler Casselman on 12/5/17.
//  Copyright © 2017 Tyler Casselman. All rights reserved.
//

import Foundation
protocol BLEEditUI: class {
    func set(saveButtonText: String)
    func set(deviceType: String)
    func set(placeholderText: String)
    func set(textFieldText: String)
    func enableSaveButton(_ enable: Bool)
}

protocol BLEEditSceneDelegate: class {
    func didCreate(device: DeviceEntry)
    func didUpdate(device: DeviceEntry)
    func didCancel()
}

class BLEEditSceneCoordinator {
    weak var delegate: BLEEditSceneDelegate?
    convenience init(forNewDevice discoveredDevice: BLEDevice, ui: BLEEditUI, deviceRepository: BLEDeviceRepository) {
        let state = BLEEditState(newEntryWith: discoveredDevice)
        self.init(state: state, ui: ui, deviceRepository: deviceRepository)
    }
    
    convenience init(forExistingEntry knownDevice: DeviceEntry, ui: BLEEditUI, deviceRepository: BLEDeviceRepository) {
        let state = BLEEditState(updateEntryWith: knownDevice)
        self.init(state: state, ui: ui, deviceRepository: deviceRepository)
    }
    
    private init(state: BLEEditState, ui: BLEEditUI, deviceRepository: BLEDeviceRepository) {
        self.state = state
        self.ui = ui
        self.deviceRepository = deviceRepository
    }
    
    func textFieldDidUpdate(with newText: String) {
        state.inputName = newText
        ui.enableSaveButton(state.saveButtonEnabled)
    }
    
    func viewDidLoad() {
        ui.set(saveButtonText: state.saveButtonText)
        ui.set(deviceType: state.deviceType)
        ui.set(placeholderText: state.namePlaceholderText)
        ui.set(textFieldText: state.inputName)
        ui.enableSaveButton(state.saveButtonEnabled)
    }
    
    func saveTapped() {
        guard let dbCommand = state.save() else {
            delegate?.didCancel()
            return
        }
        switch dbCommand {
        case .create(let device):
            deviceRepository.create(deviceEntry: device)
            delegate?.didCreate(device: device)
        case .update(let device):
            deviceRepository.update(deviceEntry: device)
            delegate?.didUpdate(device: device)
        }
        
    }
    
    private var state: BLEEditState
    private let ui: BLEEditUI
    private let deviceRepository: BLEDeviceRepository
}
