import Foundation
struct BLEListState {
    private var inRangeDevices: [BLEDevice] = []
    var knownDevices: [DeviceEntry] = [] {
        didSet {
            buildTableModel()
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
    
    private mutating func buildTableModel() {
        var sections: [[TableModel.CellConfig]] = []
        if !knownDevices.isEmpty {
            let discoveredDeviceUUIDs = Set(inRangeDevices.map { $0.identifier })
            let section = knownDevices.map(self.knownDeviceRow(discoveredDeviceIds: discoveredDeviceUUIDs))
            sections.append(section)
        }
        if !inRangeDevices.isEmpty {
            let knownDeviceUUIDs = Set(knownDevices.map { $0.identifier })
            let unknownDevices = inRangeDevices.filter { !knownDeviceUUIDs.contains($0.identifier)}
            let section = unknownDevices.map(self.discoveredDeviceRow)
            sections.append(section)
        }
        tableModel = TableModel(sections: sections)
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
                self = .discovered(device.identifier)
            }
            init(deviceEntry: DeviceEntry, inRange: Bool) {
                self = .known(deviceEntry.identifier, inRange)
            }
            case known(UUID, Bool), discovered(UUID)
        }
        struct RowChangeSet {
            let rowsAdded: [IndexPath]
            let rowsDeleted: [IndexPath]
            let rowsMoved: [(from: IndexPath, to: IndexPath)]
        }
        let sections: [[CellConfig]]
        func numRows(inSection sectionIndex: Int) -> Int {
            let section = sections[sectionIndex]
            return section.count
        }
    }
}
