//
//  RowChangeSet.swift
//  CleanArchitectureSample
//
//  Created by Tyler Casselman on 1/4/18.
//  Copyright © 2018 Tyler Casselman. All rights reserved.
//

import Foundation
struct RowAnimations {
    init(reloadedRows: [IndexPath] = [], addedRows: [IndexPath] = [], deletedRows: [IndexPath] = [], movedRows: [Move] = [], addedSections: IndexSet = [], deletedSections: IndexSet = []) {
        self.reloadedRows = reloadedRows
        self.addedRows = addedRows
        self.deletedRows = deletedRows
        self.movedRows = movedRows
        self.addedSections = addedSections
        self.deletedSections = deletedSections
    }
    //Deleting and reloading happen first (index paths refer to the original table view model)
    //Inserts take the previous deletes into account
    let reloadedRows: [IndexPath]
    let addedRows: [IndexPath]
    let deletedRows: [IndexPath]
    let movedRows: [Move]
    let addedSections: IndexSet
    let deletedSections: IndexSet
    struct Move: Equatable {
        let start: IndexPath
        let end: IndexPath
        static func ==(lhs: RowAnimations.Move, rhs: RowAnimations.Move) -> Bool {
            return lhs.start == rhs.start && lhs.end == rhs.end
        }
    }
}

struct DeviceBatchChange {
    var entriesAdded: [DeviceEntry] = []
    var entriesRemoved: [DeviceEntry] = []
    var entriesModified: [DeviceEntry] = []
    var bleDevicesMovedIntoRange: [BLEDevice] = []
    var bleDevicesMovedOutOfRange: [BLEDevice] = []
    mutating func add(entries: [DeviceEntry]) {
        entriesAdded.append(contentsOf: entries)
    }
    
    mutating func remove(entries: [DeviceEntry]) {
        entriesRemoved.append(contentsOf: entries)
    }
    
    mutating func modify(entries: [DeviceEntry]) {
        entriesModified.append(contentsOf: entries)
    }
    
    mutating func bleDevices(movedInRange devices: [BLEDevice]) {
        bleDevicesMovedIntoRange.append(contentsOf: devices)
    }
    
    mutating func bleDevices(movedOutOfRange devices: [BLEDevice]) {
        bleDevicesMovedOutOfRange.append(contentsOf: devices)
    }
}

struct DeviceListFactory {
    let newDeviceList: DeviceList
    let rowAnimations: RowAnimations
    init(oldDeviceList: DeviceList, changes: DeviceBatchChange) {
        let (newDeviceList, rowAnimations) = DeviceListFactory.buildNewDeviceList(from: oldDeviceList, with: changes)
        self.newDeviceList = newDeviceList
        self.rowAnimations = rowAnimations
    }
    
    private static func buildNewDeviceList(from oldDeviceList: DeviceList, with changes: DeviceBatchChange) -> (DeviceList, RowAnimations){
        var oldDeviceEntries: [DeviceEntry] = []
        var oldBLEDevices: [BLEDevice] = []
        var insertedSections: IndexSet = []
        for section in oldDeviceList {
            switch section {
            case .knownDevices(let deviceEntries):
                oldDeviceEntries = deviceEntries
            case .discoveredDevices(let bleDevices):
                oldBLEDevices = bleDevices
            }
        }
        
        let newDeviceEntries = oldDeviceEntries
            .appending(contentsOf: changes.entriesAdded)
            .filter {
                return !changes.entriesRemoved.contains($0)
        }
        var sections: [DeviceList.DeviceSection] = []
        if !newDeviceEntries.isEmpty {
            if oldDeviceEntries.isEmpty {
                insertedSections.insert(sections.count)
            }
            sections.append(.knownDevices(newDeviceEntries))
        }
        
        let newBLEDevices = oldBLEDevices
            .appending(contentsOf: changes.bleDevicesMovedIntoRange)
            .filter {
                return !changes.bleDevicesMovedOutOfRange.contains($0)
            }
            .filter {
                return !newDeviceEntries.map { $0.identifier }.contains($0.identifier)
        }
        if !newBLEDevices.isEmpty {
            if oldBLEDevices.isEmpty {
                insertedSections.insert(sections.count)
            }
            sections.append(.discoveredDevices(newBLEDevices))
        }
        return (DeviceList(), RowAnimations())
    }
    
}

extension Array {
    func appending(contentsOf array: [Element]) -> Array<Element> {
        var new = self
        new.append(contentsOf: array)
        return new
    }
}
