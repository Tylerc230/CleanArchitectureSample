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
    let addedSections: IndexSet
    let deletedSections: IndexSet
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
    
    var changeSet: RowChangeSet {
        let addedSections = sectionsAdded()
        let indexPathsInNewSections = devicesAdded(to: addedSections)
        let inserted = insertedDevices() + indexPathsInNewSections
        let deletedSections = sectionsDeleted()
        let deleted = deletedDevices()
        let modified = modifiedDevices()
        //Need to add the newly inserted rows plus the new positions of the rows which moved sections (converting a bleDevice to a device entry or vice versa)
        return RowChangeSet(reloadedRows: modified, addedRows: inserted, deletedRows: deleted, addedSections: addedSections, deletedSections: deletedSections)
    }
    
    private func modifiedDevices() -> [IndexPath] {
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
            .flatMap {
                oldDeviceMap[$0]
        }
    }
    
    private func insertedDevices() -> [IndexPath] {
        return preexistingSections
            .flatMap { preexistingSection -> Set<UUID> in
                guard
                    let newSectionIndex = newSectionMap[preexistingSection],
                    let oldSectionIndex = oldSectionMap[preexistingSection]
                    else {
                        return []
                }
                let newSection = newDeviceList.devices(at: newSectionIndex)
                let oldSection = oldDeviceList.devices(at: oldSectionIndex)
                return Set(newSection.deviceIdentifiers).subtracting(oldSection.deviceIdentifiers)
            }
            .flatMap {
                return newDeviceMap[$0]
        }
    }
    
    private func deletedDevices() -> [IndexPath] {
        return preexistingSections
            .flatMap { preexistingSection -> Set<UUID> in
                guard
                    let newSectionIndex = newSectionMap[preexistingSection],
                    let oldSectionIndex = oldSectionMap[preexistingSection]
                    else {
                        return []
                }
                let newSection = newDeviceList.devices(at: newSectionIndex)
                let oldSection = oldDeviceList.devices(at: oldSectionIndex)
                return Set(oldSection.deviceIdentifiers).subtracting(newSection.deviceIdentifiers)
            }
            .flatMap {
                return oldDeviceMap[$0]
        }
    }
    
    private func devicesAdded(to newSections: IndexSet) -> [IndexPath] {
        let devicesInNewSections = newSections
            .flatMap { newSectionIndex -> [UUID] in
                let section = newDeviceList[newSectionIndex]
                return section.deviceIdentifiers
        }
        return devicesInNewSections.flatMap { newDeviceMap[$0] }
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
    
    private var preexistingSections: Set<DeviceList.DeviceType> {
        let newSections = Set(newSectionMap.keys)
        let oldSections = Set(oldSectionMap.keys)
        return newSections.intersection(oldSections)
    }
    
}
