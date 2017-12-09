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
    var state: BLEEditState
    let ui: BLEEditUI
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
        ui.set(textFieldText: state.inputName)
    }
    
    func saveTapped() {
        
    }
    
}