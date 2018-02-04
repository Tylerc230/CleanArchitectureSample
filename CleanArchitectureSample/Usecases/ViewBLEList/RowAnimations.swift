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

fileprivate extension DeviceList {
    var deviceToIndexPath: [UUID: IndexPath] {
        let idIndexPathPairs: [(UUID, IndexPath)] = self
            .enumerated()
            .flatMap { args -> [(UUID, IndexPath)] in
                let (section, deviceType) = args
                return deviceType.deviceIdentifiers
                    .enumerated()
                    .map { args in
                        let (row, identifier) = args
                        return (identifier, IndexPath(row: row, section: section))
                }
        }
        return Dictionary(uniqueKeysWithValues: idIndexPathPairs)
    }
    
    var deviceTypeToSectionIndex: [DeviceType: Int] {
        let pairs = enumerated().map { ($0.1, $0.0)}
        return Dictionary(uniqueKeysWithValues: pairs)
    }
}

extension DeviceList.DeviceType: Hashable {
    static func ==(lhs: DeviceList.DeviceType, rhs: DeviceList.DeviceType) -> Bool {
        return lhs.sameType(as: rhs)
    }
    
    var hashValue: Int {
        switch self {
        case .knownDevices:
            return "A".hashValue
        case .discoveredDevices:
            return "B".hashValue
        }
    }
}

//TODO: rename to RowChangeSetFactory
struct RowChangeSetComputation {
    private let newDeviceList: DeviceList
    private let oldDeviceList: DeviceList
    private let newDeviceMap: [UUID: IndexPath]
    private let oldDeviceMap: [UUID: IndexPath]
    private let oldSectionMap: [DeviceList.DeviceType: Int]
    private let newSectionMap: [DeviceList.DeviceType: Int]
    init(newDeviceList: DeviceList, oldDeviceList: DeviceList) {
        self.newDeviceList = newDeviceList
        self.oldDeviceList = oldDeviceList
        self.newDeviceMap = newDeviceList.deviceToIndexPath
        self.oldDeviceMap = oldDeviceList.deviceToIndexPath
        self.newSectionMap = newDeviceList.deviceTypeToSectionIndex
        self.oldSectionMap = oldDeviceList.deviceTypeToSectionIndex
    }
    
    var changeSet: RowAnimations {
        let addedSections = sectionsAdded()
        let inserted = insertedDevices()
        let deletedSections = sectionsDeleted()
        let deleted = deletedDevices()
            .filter { !deletedSections.contains($0.section) }
        let movedRows = movedDevices()
        let modified = movedRows.map { $0.end }
        //Need to add the newly inserted rows plus the new positions of the rows which moved sections (converting a bleDevice to a device entry or vice versa)
        return RowAnimations(reloadedRows: modified, addedRows: inserted, deletedRows: deleted, movedRows: movedRows, addedSections: addedSections, deletedSections: deletedSections)
    }
    
    private func movedDevices() -> [RowAnimations.Move] {
        let currentDevices = Set(newDeviceMap.keys)
        let oldDevices = Set(oldDeviceMap.keys)
        let preexistingDevices = currentDevices.intersection(oldDevices)
        return preexistingDevices.filter{ identifier in
            guard
                let oldDeviceIndexPath = oldDeviceMap[identifier],
                let newDeviceIndexPath = newDeviceMap[identifier]
                else {
                    return false
            }
            let oldDeviceType = oldDeviceList.devices(at: oldDeviceIndexPath.section)
            let newDeviceType = newDeviceList.devices(at: newDeviceIndexPath.section)
            let preexistingOldDevices = oldDeviceType.deviceIdentifiers.filter(preexistingDevices.contains)
            let preexistingNewDevices = newDeviceType.deviceIdentifiers.filter(preexistingDevices.contains)
            switch (oldDeviceType, newDeviceType) {
            case (.knownDevices(let oldDevices), .knownDevices(let newDevices)):
                let oldDevice = oldDevices[oldDeviceIndexPath.row]
                let newDevice = newDevices[newDeviceIndexPath.row]
                let deviceModified = oldDevice != newDevice
                return preexistingOldDevices.index(of: identifier) != preexistingNewDevices.index(of: identifier) && deviceModified
            case (.discoveredDevices(let oldDevices), .discoveredDevices(let newDevices)):
                let oldDevice = oldDevices[oldDeviceIndexPath.row]
                let newDevice = newDevices[newDeviceIndexPath.row]
                let deviceModified = oldDevice != newDevice
                return preexistingOldDevices.index(of: identifier) != preexistingNewDevices.index(of: identifier) && deviceModified
            default://Device moved sections
                return true
            }
            }
            .flatMap { identifier -> RowAnimations.Move? in
                guard
                    let oldDeviceIndex = oldDeviceMap[identifier],
                    let newDeviceIndex = newDeviceMap[identifier]
                    else {
                        return nil
                }
                return RowAnimations.Move(start: oldDeviceIndex, end: newDeviceIndex)
        }
    }
    
    private func insertedDevices() -> [IndexPath] {
        let newDevices = newDeviceList.flatMap { $0.deviceIdentifiers }
        let oldDevices = oldDeviceList.flatMap { $0.deviceIdentifiers }
        return Set(newDevices)
            .subtracting(oldDevices)
            .flatMap { newDeviceMap[$0] }
    }
    
    private func deletedDevices() -> [IndexPath] {
        let newDevices = newDeviceList.flatMap { $0.deviceIdentifiers }
        let oldDevices = oldDeviceList.flatMap { $0.deviceIdentifiers }
        return Set(oldDevices)
            .subtracting(newDevices)
            .flatMap { oldDeviceMap[$0] }
    }
    
    private func sectionsAdded() -> IndexSet {
        let oldSections = Set(oldSectionMap.keys)
        let newSections = Set(newSectionMap.keys)
        let addedSections = newSections.subtracting(oldSections)
        let addedSectionIndices = addedSections.flatMap { newSectionMap[$0] }
        return IndexSet(addedSectionIndices)
    }
    
    private func sectionsDeleted() -> IndexSet {
        let oldSections = Set(oldSectionMap.keys)
        let newSections = Set(newSectionMap.keys)
        let deletedSections = oldSections.subtracting(newSections)
        let deletedSectionIndices = deletedSections.flatMap { oldSectionMap[$0] }
        return IndexSet(deletedSectionIndices)
    }
}
