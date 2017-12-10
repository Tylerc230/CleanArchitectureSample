//
//  BLEEditSceneCoordinator.swift
//  CleanArchitectureSample
//
//  Created by Tyler Casselman on 12/5/17.
//  Copyright © 2017 Tyler Casselman. All rights reserved.
//

import Foundation
protocol BLEEditUI: class {
    func set(textFieldText: String)
    func enableSaveButton(_ enable: Bool)
}

class BLEEditSceneCoordinator {
    private var state: BLEEditState
    private let ui: BLEEditUI
    private let deviceRepository: BLEDeviceRepository
    convenience init(forNewDevice discoveredDevice: BLEDevice, ui: BLEEditUI, repository: BLEDeviceRepository) {
        let state = BLEEditState(newEntryWith: discoveredDevice)
        self.init(state: state, ui: ui, repository: repository)
    }
    
    convenience init(forExistingEntry knownDevice: DeviceEntry, ui: BLEEditUI, repository: BLEDeviceRepository) {
        let state = BLEEditState(updateEntryWith: knownDevice)
        self.init(state: state, ui: ui, repository: repository)
    }
    
    private init(state: BLEEditState, ui: BLEEditUI, repository: BLEDeviceRepository) {
        self.state = state
        self.ui = ui
        self.deviceRepository = repository
    }
    
    func textFieldDidUpdate(with newText: String) {
        state.inputName = newText
        ui.enableSaveButton(state.saveButtonEnabled)
    }
    
    func viewDidLoad() {
        ui.set(textFieldText: state.inputName)
    }
    
    func saveTapped() {
        guard let deviceToSave = state.validDeviceEntry else {
            return
        }
        deviceRepository.save(device: deviceToSave)
    }
    
}
