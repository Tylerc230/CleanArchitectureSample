//
//  BLEEditState.swift
//  CleanArchitectureSample
//
//  Created by Tyler Casselman on 12/4/17.
//  Copyright © 2017 Tyler Casselman. All rights reserved.
//
import Foundation

struct BLEEditState {
    init(newEntryWith discoveredDevice: BLEDevice) {
        inputName = ""
        identifier = discoveredDevice.identifier
        type = discoveredDevice.type
        namePlaceholderText = "Name your new device"
    }
    
    init(updateEntryWith knownDevice: DeviceEntry) {
        inputName = knownDevice.name
        identifier = knownDevice.identifier
        type = knownDevice.type
        namePlaceholderText = "Update your existing device"
    }
    
    var inputName: String
    let namePlaceholderText: String
    var saveButtonEnabled: Bool {
        return isInputNameValid
    }
    
    var validDeviceEntry: DeviceEntry? {
        guard isInputNameValid else {
            return nil
        }
        return DeviceEntry(identifier: identifier, name: inputName, type: type)
    }
    
    private var isInputNameValid: Bool {
        return inputName.count >= 3
    }
    private let identifier: UUID
    private let type: String
    
}
