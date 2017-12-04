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
        let currentDevices = Set(newDeviceTablePositions.keys)
        let oldDevices = Set(oldDeviceTablePositions.keys)
        let devicesWhichMovedSections = currentDevices
            .filter { identifier in
                guard
                    let oldIndex = oldDeviceTablePositions[identifier],
                    let newIndex = newDeviceTablePositions[identifier]
                    else {
                        return false
                }
                let movedSections = oldIndex.section != newIndex.section
                return movedSections
        }
        
        let insertedDevices = currentDevices
            .subtracting(oldDevices)
        
        let insertedIndexPaths = insertedDevices
            .union(devicesWhichMovedSections)
            .flatMap { newDeviceTablePositions[$0] }
        
        let deletedIndexPaths = devicesWhichMovedSections.flatMap { oldDeviceTablePositions[$0] }
        return TableModel.RowChangeSet(addedRows: insertedIndexPaths, deletedRows: deletedIndexPaths)
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
                self = .discovered
            }
            init(deviceEntry: DeviceEntry, inRange: Bool) {
                self = .known(inRange)
            }
            case known(Bool), discovered
        }
        
        struct RowChangeSet {
            let addedRows: [IndexPath]
            let deletedRows: [IndexPath]
        }
        
        private let sections: [[CellConfig]]
    }
}
