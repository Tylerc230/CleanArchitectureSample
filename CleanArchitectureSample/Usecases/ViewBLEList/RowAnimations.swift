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
    //Deleting -and reloading- happen first (index paths refer to the original table view model)
    //Inserts take the previous deletes into account
    //Actually we reload once the animtion is complete
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
    let newDeviceList: DeviceList

    init(oldDeviceList: DeviceList, changes: DeviceBatchChange) {
        self.oldDeviceList = oldDeviceList
        self.changes = changes
        self.newDeviceList = deviceList(from: oldDeviceList, changes: changes)
    }
    
    var bleDeviceRangeStateChanges: [BLEDevice] {
        return (changes.bleDevicesMovedOutOfRange + changes.bleDevicesMovedIntoRange)
    }
    
    func insertedSections() -> IndexSet {
        let oldBLEDevices = oldDeviceList.bleDevices
        let newBLEDevices = newDeviceList.bleDevices
        let oldDeviceEntries = oldDeviceList.deviceEntries
        let newDeviceEntries = newDeviceList.deviceEntries
        var insertedSections: IndexSet = []
        if !newDeviceEntries.isEmpty && oldDeviceEntries.isEmpty, let addedIndex = newDeviceList.index(for: .knownDevices([])) {
            insertedSections.insert(addedIndex)
        }
        if !newBLEDevices.isEmpty && oldBLEDevices.isEmpty, let discoveredIndex = newDeviceList.index(for: .discoveredDevices([])) {
            insertedSections.insert(discoveredIndex)
        }
        return insertedSections
    }
    
    func removedSections() -> IndexSet {
        let oldBLEDevices = oldDeviceList.bleDevices
        let newBLEDevices = newDeviceList.bleDevices
        let oldDeviceEntries = oldDeviceList.deviceEntries
        let newDeviceEntries = newDeviceList.deviceEntries
        var removedSections: IndexSet = []
        if newDeviceEntries.isEmpty && !oldDeviceEntries.isEmpty, let removedIndex = oldDeviceList.index(for: .knownDevices([])) {
            removedSections.insert(removedIndex)
        }
        if newBLEDevices.isEmpty && !oldBLEDevices.isEmpty, let removedIndex = oldDeviceList.index(for: .discoveredDevices([])) {
            removedSections.insert(removedIndex)
        }
        return removedSections
    }
    
    func insertedRows() -> [IndexPath] {
        let allNewDevicesIdentifiers = newDeviceList.allDeviceIdentifiers
        let allOldDeviceIdentifiers = oldDeviceList.allDeviceIdentifiers
        let addedDeviceIdentifiers = allNewDevicesIdentifiers.subtracting(allOldDeviceIdentifiers)
        return addedDeviceIdentifiers.flatMap { newDeviceList.indexPath(for: $0) }
    }
    
    func rowsMovedBetweenSections() -> [RowAnimations.Move] {
        return (changes.entriesRemoved + changes.entriesAdded)
            .filter(newDeviceList.isInRange)
            .flatMap { deviceEntry in
                guard
                    let newIndexPath = newDeviceList.indexPath(for: deviceEntry.identifier),
                    let oldIndexPath = oldDeviceList.indexPath(for: deviceEntry.identifier)
                    else {
                        return nil
                }
                return .init(start: oldIndexPath, end: newIndexPath)
        }
    }
    
    func rowsMovedInSection() -> [RowAnimations.Move] {
        let oldDeviceEntries = oldDeviceList.deviceEntries
        let newDeviceEntries = newDeviceList.deviceEntries
        
        let persistantDeviceEntries = Set(newDeviceEntries).intersection(oldDeviceEntries)
        let deviceEntriesWhichChangedRangeState =  persistantDeviceEntries.filter {
            return bleDeviceRangeStateChanges.map { $0.identifier }.contains($0.identifier)
        }
        let oldPositions = oldDeviceEntries.filter(persistantDeviceEntries.contains)
        let newPositions = newDeviceEntries.filter(persistantDeviceEntries.contains)
        return (changes.entriesModified + deviceEntriesWhichChangedRangeState)
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
    }
    
    func deviceEntriesWithRangeStateChanges() -> [IndexPath] {
        let oldDeviceEntries = oldDeviceList.deviceEntries
        return bleDeviceRangeStateChanges
            .map { $0.identifier }
            .filter { oldDeviceEntries.map { $0.identifier }.contains($0) }
            .flatMap { newDeviceList.indexPath(for: $0)}
    }
    
    func reloadedRows() -> [IndexPath] {
        let entriesWithChangedInRangeState = deviceEntriesWithRangeStateChanges()
        return changes.entriesModified
            .flatMap {
                return newDeviceList.indexPath(for: $0.identifier)
            }
            + entriesWithChangedInRangeState
    }
    
    func rowAnimations() -> RowAnimations {
        let insertedSections = self.insertedSections()
        let removedSections = self.removedSections()
        let insertedRows = self.insertedRows()
        let movedDeviceEntries = self.rowsMovedInSection()
        let devicesWhichMovedBetweenSections = rowsMovedBetweenSections()
        let reloadedRows = self.reloadedRows()
            + devicesWhichMovedBetweenSections.map { $0.end }
        let deletedRows = self.deletedRows()
            .filter {
                return !removedSections.contains($0.section)
        }
        return RowAnimations(reloadedRows: reloadedRows, addedRows: insertedRows, deletedRows: deletedRows, movedRows: devicesWhichMovedBetweenSections + movedDeviceEntries, addedSections: insertedSections, deletedSections: removedSections)
    }
    
    func deletedRows() -> [IndexPath] {
        return changes.entriesRemoved
            .flatMap {
                return oldDeviceList.indexPath(for: $0.identifier)
        }
    }
    
}

private func deviceList(from oldDeviceList: DeviceList, changes: DeviceBatchChange) -> DeviceList {
    let discoveredDevices = allDiscoveredDevices(oldDeviceList: oldDeviceList, changes: changes)
    let oldDeviceEntries = oldDeviceList.deviceEntries
    let newDeviceEntries = oldDeviceEntries
        .filter { !changes.entriesModified.contains($0) }
        .filter { !changes.entriesRemoved.contains($0) }
        .appending(contentsOf: changes.entriesAdded)
        .appending(contentsOf: changes.entriesModified)
    var sections: [DeviceList.DeviceSection] = []
    if !newDeviceEntries.isEmpty {
        let sorted = sort(deviceEntries: newDeviceEntries, discoveredDevices: discoveredDevices)
        sections.append(.knownDevices(sorted))
    }
    
    let newBLEDevices = discoveredDevices
        .filter {
            return !newDeviceEntries.map { $0.identifier }.contains($0.identifier)
    }
    if !newBLEDevices.isEmpty {
        let sorted = newBLEDevices.sorted {
            return $0.discoveredTime < $1.discoveredTime
        }
        sections.append(.discoveredDevices(sorted))
    }
    
    return DeviceList(sections: sections, inRangeDevices: discoveredDevices)
}

private func sort(deviceEntries: [DeviceEntry], discoveredDevices: Set<BLEDevice>) -> [DeviceEntry] {
    func isInRange(_ deviceEntry: DeviceEntry) -> Bool {
        return discoveredDevices.contains{ $0.identifier == deviceEntry.identifier }
    }
    let inRangeDevices = deviceEntries
        .filter(isInRange)
        .sorted { $0.name < $1.name }
    let outOfRange = deviceEntries
        .filter { !isInRange($0) }
        .sorted { $0.name < $1.name }
    return inRangeDevices + outOfRange
}
private func allDiscoveredDevices(oldDeviceList: DeviceList, changes: DeviceBatchChange) -> Set<BLEDevice> {
    let oldDiscoveredDevices = oldDeviceList.discoveredDevices
    let addedDevices = changes.bleDevicesMovedIntoRange
    let removedDevices = changes.bleDevicesMovedOutOfRange
    return oldDiscoveredDevices
        .union(addedDevices)
        .subtracting(removedDevices)
}

extension Array {
    func appending(contentsOf array: [Element]) -> Array<Element> {
        var new = self
        new.append(contentsOf: array)
        return new
    }
}
