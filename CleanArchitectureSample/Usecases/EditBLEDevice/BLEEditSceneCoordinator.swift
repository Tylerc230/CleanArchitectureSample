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
    func didSave(device: DeviceEntry)
    func didCancel()
}

class BLEEditSceneCoordinator {
    weak var delegate: BLEEditSceneDelegate?
    convenience init(forNewDevice discoveredDevice: BLEDevice, ui: BLEEditUI) {
        let state = BLEEditState(newEntryWith: discoveredDevice)
        self.init(state: state, ui: ui)
    }
    
    convenience init(forExistingEntry knownDevice: DeviceEntry, ui: BLEEditUI) {
        let state = BLEEditState(updateEntryWith: knownDevice)
        self.init(state: state, ui: ui)
    }
    
    private init(state: BLEEditState, ui: BLEEditUI) {
        self.state = state
        self.ui = ui
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
        guard let deviceToSave = state.validDeviceEntry else {
            delegate?.didCancel()
            return
        }
        delegate?.didSave(device: deviceToSave)
    }
    
    private var state: BLEEditState
    private let ui: BLEEditUI
}
