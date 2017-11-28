import Foundation
struct BLEListState {
    private var inRangeDevices: [BLEDevice] = []
    private var previousDevices: Set<UUID> = []
    var knownDevices: [DeviceEntry] = [] {
        didSet {
            _ = buildTableModel()
        }
    }
    private var tableModel = TableModel(sections: [])
    var showNoDevicesCopy: Bool {
        return inRangeDevices.isEmpty
    }
    
    var numSectionsInList: Int {
        return tableModel.sections.count
    }

    func numRows(inSection section: Int) -> Int {
        return tableModel.numRows(inSection: section)
    }
    
    func cellConfig(atRow row: Int, section: Int) -> TableModel.CellConfig {
        return tableModel.sections[section][row]
    }
    
    mutating func append(discoveredBLEDevices devices: [BLEDevice]) -> TableModel.RowChangeSet {
        inRangeDevices += devices
        return buildTableModel()
    }
    
    private mutating func buildTableModel() -> TableModel.RowChangeSet {
        var sections: [[TableModel.CellConfig]] = []
        if !knownDevices.isEmpty {
            let discoveredDeviceUUIDs = Set(inRangeDevices.map { $0.identifier })
            let section = knownDevices.map(self.knownDeviceRow(discoveredDeviceIds: discoveredDeviceUUIDs))
            sections.append(section)
        }
        
        let knownDeviceUUIDs = Set(knownDevices.map { $0.identifier })
        let unknownDevices = inRangeDevices.filter { !knownDeviceUUIDs.contains($0.identifier)}
        if !inRangeDevices.isEmpty {
            let section = unknownDevices.map(self.discoveredDeviceRow)
            sections.append(section)
        }
        let changeSet = createChangeSet(section0: knownDevices, section1: unknownDevices)
        previousDevices = Set(knownDevices.map { $0.identifier} + inRangeDevices.map{ $0.identifier })
        tableModel = TableModel(sections: sections)
        return changeSet
    }
    
    func createChangeSet(section0: [DeviceEntry], section1: [BLEDevice]) -> TableModel.RowChangeSet {
        let newRowsInSection0: [IndexPath] = section0
            .map { $0.identifier }
            .enumerated()
            .filter { (_, identifier) in !self.previousDevices.contains(identifier) }
            .map { (args) in
                let (row, _) = args
                return IndexPath(indexes: [0, row])
        }
        let newRowsInSection1: [IndexPath] = section1
            .map { $0.identifier }
            .enumerated()
            .filter { (_, identifier) in !self.previousDevices.contains(identifier) }
            .map { arg in
                let (row, _) = arg
                return IndexPath(indexes: [1, row])
        }
        return TableModel.RowChangeSet(addedRows: newRowsInSection0 + newRowsInSection1)
    }
    
    private func knownDeviceRow(discoveredDeviceIds: Set<UUID>) -> (DeviceEntry) -> TableModel.CellConfig {
        return { device in
            let inRange = discoveredDeviceIds.contains(device.identifier)
            return .known(inRange)
        }
    }
    
    private func discoveredDeviceRow(from device: BLEDevice) -> TableModel.CellConfig {
        //todo: move to CellConfig contructor
        return .discovered
    }
    
    struct TableModel {
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
        }
        let sections: [[CellConfig]]
        func numRows(inSection sectionIndex: Int) -> Int {
            let section = sections[sectionIndex]
            return section.count
        }
    }
}
