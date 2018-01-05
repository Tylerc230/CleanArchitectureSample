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
        let addedSections = sectionsAdded()
        let devicesInNewSection = addedSections.flatMap { section in
            return self.newDeviceMap.filter { (_, indexPath) -> Bool in
                return indexPath.section == section
                }
                .map { (uuid, _) in
                    return uuid
            }
        }
        let inserted = insertedDevices().union(devicesInNewSection)
        let deletedSections = sectionsDeleted()
        let deleted = deletedDevices()
        let modified = modifiedDevices()
        //Need to add the newly inserted rows plus the new positions of the rows which moved sections (converting a bleDevice to a device entry or vice versa)
        let insertedIndexPaths = inserted
            .flatMap { newDeviceMap[$0] }
        let deletedIndexPaths = deleted.flatMap { oldDeviceMap[$0] }
        let reloadedIndexPaths = modified.flatMap { oldDeviceMap[$0] }//Reloads happen before inserts so we use the old device map
        return RowChangeSet(reloadedRows: reloadedIndexPaths, addedRows: insertedIndexPaths, deletedRows: deletedIndexPaths, reloadedSections:[], addedSections: IndexSet(addedSections), deletedSections: deletedSections)
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
        let devicesAddedToSections = newDeviceList.flatMap { (deviceType) -> Set<UUID> in
            guard let oldDeviceType = oldDeviceList.first (where:{ deviceType.sameType(as: $0)}) else {
                return []
            }
            switch (deviceType, oldDeviceType) {
            case (.knownDevices(let newDevicesInSection), .knownDevices(let oldDevicesInSection)):
                return Set(newDevicesInSection.map{$0.identifier}).subtracting(Set(oldDevicesInSection.map {$0.identifier}))
            case (.discoveredDevices(let newDevicesInSection), .discoveredDevices(let oldDevicesInSection)):
                return Set(newDevicesInSection.map{$0.identifier}).subtracting(Set(oldDevicesInSection.map{$0.identifier}))
            default:
                return []
            }
        }
        return Set(devicesAddedToSections)
    }
    
    private func deletedDevices() -> Set<UUID> {
        let devicesAddedToSections = newDeviceList.flatMap { (deviceType) -> Set<UUID> in
            guard let oldDeviceType = oldDeviceList.first (where:{ deviceType.sameType(as: $0)}) else {
                return []
            }
            switch (deviceType, oldDeviceType) {
            case (.knownDevices(let newDevicesInSection), .knownDevices(let oldDevicesInSection)):
                return Set(oldDevicesInSection.map{$0.identifier}).subtracting(Set(newDevicesInSection.map {$0.identifier}))
            case (.discoveredDevices(let newDevicesInSection), .discoveredDevices(let oldDevicesInSection)):
                return Set(oldDevicesInSection.map{$0.identifier}).subtracting(Set(newDevicesInSection.map{$0.identifier}))
            default:
                return []
            }
        }
        return Set(devicesAddedToSections)
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
