//
//  RowChangeSet.swift
//  CleanArchitectureSample
//
//  Created by Tyler Casselman on 1/4/18.
//  Copyright © 2018 Tyler Casselman. All rights reserved.
//

import Foundation
struct RowChangeSet {
    //Deleting and reloading happen first (index paths refer to the original table view model)
    //Inserts take the previous deletes into account
    let reloadedRows: [IndexPath]
    let addedRows: [IndexPath]
    let deletedRows: [IndexPath]
    let reloadedSections: IndexSet
    let addedSections: IndexSet
    let deletedSections: IndexSet
}

fileprivate typealias DeviceIndexPathMap = [UUID: IndexPath]
fileprivate extension DeviceList {
    var deviceToIndexPath: DeviceIndexPathMap {
        let idIndexPathPairs: [(UUID, IndexPath)] = self
            .enumerated()
            .flatMap { (section, deviceType) -> [(UUID, IndexPath)] in
                switch deviceType {
                case .knownDevices(let devices):
                    return devices
                        .enumerated()
                        .map { (row, device) in
                            return (device.identifier, IndexPath(row: row, section: section))
                    }
                case .discoveredDevices(let devices):
                    return devices
                        .enumerated()
                        .map { (row, device) in
                            return (device.identifier, IndexPath(row: row, section: section))
                    }
                }
        }
        return Dictionary(uniqueKeysWithValues: idIndexPathPairs)
    }
}

struct RowChangeSetComputation {
    private let newDeviceList: DeviceList
    private let oldDeviceList: DeviceList
    private let newDeviceMap: DeviceIndexPathMap
    private let oldDeviceMap: DeviceIndexPathMap
    init(newDeviceList: DeviceList, oldDeviceList: DeviceList) {
        self.newDeviceList = newDeviceList
        self.oldDeviceList = oldDeviceList
        self.newDeviceMap = newDeviceList.deviceToIndexPath
        self.oldDeviceMap = oldDeviceList.deviceToIndexPath
    }
    
    var changeSet: RowChangeSet {
        let inserted = insertedDevices()
        let devicesWhichMovedSections = movedSections()
        
        //Need to add the newly inserted rows plus the new positions of the rows which moved sections (converting a bleDevice to a device entry or vice versa)
        let insertedIndexPaths = inserted
            .union(devicesWhichMovedSections)
            .flatMap { newDeviceMap[$0] }
        
        let addedSections = sectionsAdded()
        let deletedSections = sectionsDeleted()
        let deletedIndexPaths = devicesWhichMovedSections.flatMap { oldDeviceMap[$0] }
        let modified = modifiedDevices()
        let reloadedIndexPaths = modified.flatMap { oldDeviceMap[$0] }//Reloads happen before inserts so we use the old device map
        return RowChangeSet(reloadedRows: reloadedIndexPaths, addedRows: insertedIndexPaths, deletedRows: deletedIndexPaths, reloadedSections:IndexSet(), addedSections: IndexSet(addedSections), deletedSections: deletedSections)
    }
    
    private func modifiedDevices() -> Set<UUID> {
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
            switch (oldDeviceType, newDeviceType) {
            case (.knownDevices(let oldDevices), .knownDevices(let newDevices)):
                return oldDevices[oldDeviceIndexPath.row] != newDevices[newDeviceIndexPath.row]
            case (.discoveredDevices(let oldDevices), .discoveredDevices(let newDevices)):
                return oldDevices[oldDeviceIndexPath.row] != newDevices[newDeviceIndexPath.row]
            default://Device moved sections
                return false
            }
        }
    }
    
    private func insertedDevices() -> Set<UUID> {
        let currentDevices = Set(newDeviceMap.keys)
        let oldDevices = Set(oldDeviceMap.keys)
        return currentDevices.subtracting(oldDevices)
    }
    
    private func movedSections() -> Set<UUID> {
        let currentDevices = Set(newDeviceMap.keys)
        return currentDevices
            .filter { identifier in
                guard
                    let oldIndex = oldDeviceMap[identifier],
                    let newIndex = newDeviceMap[identifier]
                    else {
                        return false
                }
                return  oldIndex.section != newIndex.section
        }
    }
    
    private func sectionsAdded() -> IndexSet {
        let sections = newDeviceList
            .enumerated()
            .filter {
                let (_, deviceType) = $0
                return !oldDeviceList.contains { deviceType.sameType(as: $0) }
            }
            .map { (offset, _) in
                return offset
        }
        return IndexSet(sections)
    }
    
    private func sectionsDeleted() -> IndexSet {
        let sections = oldDeviceList
            .enumerated()
            .filter {
                let (_, deviceType) = $0
                return !newDeviceList.contains { deviceType.sameType(as: $0) }
            }
            .map { (offset, _) in
                return offset
        }
        return IndexSet(sections)
        
    }
}
