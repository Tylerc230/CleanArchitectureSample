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
        deviceType = discoveredDevice.type
        mode = .newEntry(discoveredDevice)
        namePlaceholderText = "Name your new device"
    }
    
    init(updateEntryWith knownDevice: DeviceEntry) {
        inputName = knownDevice.name
        deviceType = knownDevice.type
        mode = .updateEntry(knownDevice)
        namePlaceholderText = "Update your existing device"
    }
    
    var inputName: String
    let namePlaceholderText: String
    let deviceType: String
    var saveButtonText: String {
        switch mode {
        case .newEntry(_):
            return "save"
        case .updateEntry(_):
            return "update"
        }
    }
    var saveButtonEnabled: Bool {
        return isValidForSaving
    }
    
    func save() -> Command? {
        guard let device = validDeviceEntry else {
            return nil
        }
        switch mode {
        case .newEntry(_):
            return .create(device)
        case .updateEntry(_):
            return .update(device)
        }
    }
    
    enum Command {
        case create(DeviceEntry), update(DeviceEntry)
    }
    
    private var validDeviceEntry: DeviceEntry? {
        guard
            isValidForSaving
            else {
                return nil
        }
        return DeviceEntry(identifier: identifier, name: inputName, type: type)
    }
    
    private enum Mode {
        case newEntry(BLEDevice), updateEntry(DeviceEntry)
    }
    
    private var isValidForSaving: Bool {
        switch mode {
        case .newEntry(_):
            return isInputNameValid
        case .updateEntry(let initialEntry):
            let nameDidChange = initialEntry.name != inputName
            return nameDidChange && isInputNameValid
        }
    }
    private var isInputNameValid: Bool {
        return inputName.count >= 3
    }
    private let mode: Mode
    private var identifier: UUID {
        switch mode {
        case .newEntry(let discoveredDevice):
            return discoveredDevice.identifier
        case .updateEntry(let knownDevice):
            return knownDevice.identifier
        }
    }
    
    private var type: String {
        switch mode {
        case .newEntry(let discoveredDevice):
            return discoveredDevice.type
        case .updateEntry(let knownDevice):
            return knownDevice.type
        }
    }
}
