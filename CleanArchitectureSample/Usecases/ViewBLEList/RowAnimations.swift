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
    let oldDeviceList: DeviceList
    let changes: DeviceBatchChange
    private let discoveredDevices: Set<UUID>
    
    init(oldDeviceList: DeviceList, changes: DeviceBatchChange) {
        self.oldDeviceList = oldDeviceList
        self.changes = changes
        self.discoveredDevices = allDiscoveredDevices(oldDeviceList: oldDeviceList, changes: changes)
    }
    
    func buildNewDeviceList() -> (DeviceList, RowAnimations){
        let newDeviceList = deviceList
        let oldDeviceEntries = oldDeviceList.deviceEntries
        let oldBLEDevices = oldDeviceList.bleDevices
        let newDeviceEntries = newDeviceList.deviceEntries
        let newBLEDevices = newDeviceList.bleDevices
        
        //Calculate animations
        var insertedSections: IndexSet = []
        var removedSections: IndexSet = []
        if !newDeviceEntries.isEmpty && oldDeviceEntries.isEmpty, let addedIndex = newDeviceList.index(for: .knownDevices([])) {
            insertedSections.insert(addedIndex)
        }
        if newDeviceEntries.isEmpty && !oldDeviceEntries.isEmpty, let removedIndex = oldDeviceList.index(for: .knownDevices([])) {
            removedSections.insert(removedIndex)
        }
        if !newBLEDevices.isEmpty && oldBLEDevices.isEmpty, let discoveredIndex = newDeviceList.index(for: .discoveredDevices([])) {
            insertedSections.insert(discoveredIndex)
        }
        if newBLEDevices.isEmpty && !oldBLEDevices.isEmpty, let removedIndex = oldDeviceList.index(for: .discoveredDevices([])) {
            removedSections.insert(removedIndex)
        }
        let allNewDevicesIdentifiers = newDeviceList.allDeviceIdentifiers
        let allOldDeviceIdentifiers = oldDeviceList.allDeviceIdentifiers
        let addedDeviceIdentifiers = allNewDevicesIdentifiers.subtracting(allOldDeviceIdentifiers)
        let insertedRows = addedDeviceIdentifiers.flatMap { newDeviceList.indexPath(for: $0) }
        let devicesWhichMovedSections: [RowAnimations.Move] = changes.entriesAdded
            .filter { newDeviceEntry  in
                return oldBLEDevices.contains { $0.identifier == newDeviceEntry.identifier }
            }
            .flatMap { deviceEntry in
                guard
                    let newIndexPath = newDeviceList.indexPath(for: deviceEntry.identifier),
                    let oldIndexPath = oldDeviceList.indexPath(for: deviceEntry.identifier)
                    else {
                        return nil
                }
                return .init(start: oldIndexPath, end: newIndexPath)
        }
        let persistantDeviceEntries = Set(newDeviceEntries).intersection(oldDeviceEntries)
        let oldPositions = oldDeviceEntries.filter(persistantDeviceEntries.contains)
        let newPositions = newDeviceEntries.filter(persistantDeviceEntries.contains)
        let movedDeviceEntries = changes.entriesModified
            .flatMap { modifiedEntry -> (DeviceEntry, Int, Int)? in
                guard
                    let oldIndex = oldPositions.index(of: modifiedEntry),
                    let newIndex = newPositions.index(of: modifiedEntry)
                    else {
                        return nil
                }
                return (modifiedEntry, oldIndex, newIndex)
            }
            .filter { args in
                let (_, oldIndex, newIndex) = args
                return oldIndex != newIndex
            }
            .flatMap { args -> RowAnimations.Move? in
                let (deviceEntry, _, _) = args
                guard
                    let oldIndexPath = oldDeviceList.indexPath(for: deviceEntry.identifier),
                    let newIndexPath = newDeviceList.indexPath(for: deviceEntry.identifier)
                    else {
                        return nil
                }
                return RowAnimations.Move(start: oldIndexPath, end: newIndexPath)
        }
        let reloadedRows = changes.entriesModified
            .flatMap {
                return newDeviceList.indexPath(for: $0.identifier)
            }
            + devicesWhichMovedSections.map { $0.end }
        let rowAnimations = RowAnimations(reloadedRows: reloadedRows, addedRows: insertedRows, movedRows: devicesWhichMovedSections + movedDeviceEntries, addedSections: insertedSections, deletedSections: removedSections)
        return (newDeviceList, rowAnimations)
    }
    
    var deviceList: DeviceList {
        let oldDeviceEntries = oldDeviceList.deviceEntries
        let oldBLEDevices = oldDeviceList.bleDevices
        let newDeviceEntries = oldDeviceEntries
            .filter { !changes.entriesModified.contains($0) }
            .filter { !changes.entriesRemoved.contains($0) }
            .appending(contentsOf: changes.entriesAdded)
            .appending(contentsOf: changes.entriesModified)
        var sections: [DeviceList.DeviceSection] = []
        if !newDeviceEntries.isEmpty {
            let sorted = sort(deviceEntries: newDeviceEntries)
            sections.append(.knownDevices(sorted))
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
            sections.append(.discoveredDevices(newBLEDevices))
        }
        
        return DeviceList(sections: sections, inRangeDevices: discoveredDevices)
    }
    
    func isInRange(_ device: DeviceEntry) -> Bool {
        return discoveredDevices.contains(device.identifier)
    }
    
    private func sort(deviceEntries: [DeviceEntry]) -> [DeviceEntry] {
        let inRangeDevices = deviceEntries
            .filter(self.isInRange)
            .sorted { $0.name < $1.name }
        let outOfRange = deviceEntries
            .filter { !self.isInRange($0) }
            .sorted { $0.name < $1.name }
        return inRangeDevices + outOfRange
    }
}

private func allDiscoveredDevices(oldDeviceList: DeviceList, changes: DeviceBatchChange) -> Set<UUID> {
    let oldDiscoveredDevices = oldDeviceList.discoveredDevices
    let addedDeviceIds = changes.bleDevicesMovedIntoRange.map { $0.identifier }
    let removedDeviceIds = changes.bleDevicesMovedOutOfRange.map { $0.identifier }
    return oldDiscoveredDevices
        .union(addedDeviceIds)
        .subtracting(removedDeviceIds)
}

extension Array {
    func appending(contentsOf array: [Element]) -> Array<Element> {
        var new = self
        new.append(contentsOf: array)
        return new
    }
}
