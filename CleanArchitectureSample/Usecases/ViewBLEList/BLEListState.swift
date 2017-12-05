import Foundation
struct BLEListState {
    private typealias DeviceIndexPathMap = [UUID: IndexPath]
    private var inRangeDevices: [BLEDevice] = []
    private var knownDevices: [DeviceEntry] = []
    private var deviceTablePositions: DeviceIndexPathMap = [:]
    private (set) var tableModel = TableModel(sections: [])
    var showNoDevicesCopy: Bool {
        return inRangeDevices.isEmpty
    }
    
    func deviceEntry(at index: Int) -> DeviceEntry {
        return knownDevices[index]
    }
    
    func discoveredDevice(at index: Int) -> BLEDevice {
        return inRangeDevices[index]
    }
    
    mutating func append(discoveredBLEDevices devices: [BLEDevice]) -> TableModel.RowChangeSet {
        inRangeDevices += devices
        return buildTableModel()
    }
    
    mutating func append(deviceEntries: [DeviceEntry]) -> TableModel.RowChangeSet {
        knownDevices += deviceEntries
        return buildTableModel()
    }
    
    private mutating func buildTableModel() -> TableModel.RowChangeSet {
        var sections: [[TableModel.CellConfig]] = []
        if !knownDevices.isEmpty {
            let discoveredDeviceUUIDs = Set(inRangeDevices.map { $0.identifier })
            let section = knownDevices
                .map { knownDevice -> TableModel.CellConfig in
                    let inRange = discoveredDeviceUUIDs.contains(knownDevice.identifier)
                    return TableModel.CellConfig(deviceEntry: knownDevice, inRange: inRange)
            }
            sections.append(section)
        }
        
        let knownDeviceUUIDs = Set(knownDevices.map { $0.identifier })
        let unknownDevices = inRangeDevices.filter { !knownDeviceUUIDs.contains($0.identifier)}
        if !inRangeDevices.isEmpty {
            let section = unknownDevices.map(TableModel.CellConfig.init)
            sections.append(section)
        }
        let knownDeviceIDPathPairs = knownDevices
            .enumerated()
            .map { (row, deviceEntry) in
                return (deviceEntry.identifier, IndexPath(row: row, section: 0))
        }
        let unknownDeviceIDPathPairs = unknownDevices
            .enumerated()
            .map { (row, bleDevice) in
                return (bleDevice.identifier, IndexPath(row: row, section: 1))
        }
        let newDeviceTablePositions = Dictionary(uniqueKeysWithValues: knownDeviceIDPathPairs + unknownDeviceIDPathPairs)
        let changeSet = createChangeSet(newDeviceTablePositions: newDeviceTablePositions, oldDeviceTablePositions: deviceTablePositions)
        deviceTablePositions = newDeviceTablePositions
        tableModel = TableModel(sections: sections)
        return changeSet
    }
    
    private func createChangeSet(newDeviceTablePositions: DeviceIndexPathMap, oldDeviceTablePositions: DeviceIndexPathMap) -> TableModel.RowChangeSet {
        let inserted = insertedDevices(newDevices: newDeviceTablePositions, oldDevices: oldDeviceTablePositions)
        let devicesWhichMovedSections = movedSections(newDevices: newDeviceTablePositions, oldDevices: oldDeviceTablePositions)

        //Need to add the newly inserted rows plus the new positions of the rows which moved sections
        let insertedIndexPaths = inserted
            .union(devicesWhichMovedSections)
            .flatMap { newDeviceTablePositions[$0] }
        
        let addedSections = sectionsAdded(newDevices: newDeviceTablePositions, oldDevices: oldDeviceTablePositions)
        let deletedIndexPaths = devicesWhichMovedSections.flatMap { oldDeviceTablePositions[$0] }
        return TableModel.RowChangeSet(addedRows: insertedIndexPaths, deletedRows: deletedIndexPaths, addedSections: IndexSet(addedSections))
    }
    
    private func insertedDevices(newDevices: DeviceIndexPathMap, oldDevices: DeviceIndexPathMap) -> Set<UUID> {
        let currentDevices = Set(newDevices.keys)
        let oldDevices = Set(oldDevices.keys)
        return currentDevices.subtracting(oldDevices)
    }
    
    private func movedSections(newDevices: DeviceIndexPathMap, oldDevices: DeviceIndexPathMap) -> Set<UUID> {
        let currentDevices = Set(newDevices.keys)
        return currentDevices
            .filter { identifier in
                guard
                    let oldIndex = oldDevices[identifier],
                    let newIndex = newDevices[identifier]
                    else {
                        return false
                }
                return  oldIndex.section != newIndex.section
        }
    }
    
    private func sectionsAdded(newDevices: DeviceIndexPathMap, oldDevices: DeviceIndexPathMap) -> IndexSet {
        func countSections(devicePathMap: DeviceIndexPathMap) -> Int {
            return Set(devicePathMap.values).map { $0.section }.count
        }
        let oldSectionCount = countSections(devicePathMap: oldDevices)
        let newSectionCount = countSections(devicePathMap: newDevices)
        return newSectionCount > oldSectionCount ? [1] : [0]
    }
    
    struct TableModel {
        init(sections: [[CellConfig]]) {
            self.sections = sections
        }
        
        var numSections: Int {
            return sections.count
        }
        
        func numRows(inSection sectionIndex: Int) -> Int {
            return sections[sectionIndex].count
        }
        
        func cellConfig(at indexPath: IndexPath) -> CellConfig {
            return sections[indexPath.section][indexPath.row]
        }
        
        enum CellConfig {
            init(device: BLEDevice) {
                self = .discovered(device.type)
            }
            init(deviceEntry: DeviceEntry, inRange: Bool) {
                self = .known(deviceEntry.name, deviceEntry.type, inRange)
            }
            case known(String, String, Bool), discovered(String)
        }
        
        struct RowChangeSet {
            let addedRows: [IndexPath]
            let deletedRows: [IndexPath]
            let addedSections: IndexSet
        }
        
        private let sections: [[CellConfig]]
    }
}
