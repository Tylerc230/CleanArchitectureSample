//
//  BLEEditState.swift
//  CleanArchitectureSample
//
//  Created by Tyler Casselman on 12/4/17.
//  Copyright © 2017 Tyler Casselman. All rights reserved.
//

struct BLEEditState {
    init(newEntryWith discoveredDevice: BLEDevice) {
        inputName = ""
        namePlaceholderText = "Name your new device"
    }
    
    init(updateEntryWith knownDevice: DeviceEntry) {
        inputName = knownDevice.name
        namePlaceholderText = "Update your existing device"
    }
    
    var inputName: String
    let namePlaceholderText: String
    var saveButtonEnabled: Bool {
        return isInputNameValid
    }
    
    private var isInputNameValid: Bool {
        return inputName.count >= 3
    }
    
}
