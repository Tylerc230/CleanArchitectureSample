import Foundation
struct BLEListState {
    private var inRangeDevices: [BLEDevice] = [] {
        didSet {
            buildTableModel()
        }
    }
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
    
    mutating func append(discoveredBLEDevice device: BLEDevice) {
        inRangeDevices.append(device)
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
        return .discovered
    }
    
    struct KnownDeviceRow {
        let inRange: Bool
    }
    
    struct DiscoveredDeviceRow {
        
    }
    
    struct TableModel {
        enum CellConfig {
            case known(Bool), discovered
        }
        let sections: [[CellConfig]]
        func numRows(inSection sectionIndex: Int) -> Int {
            let section = sections[sectionIndex]
            return section.count
        }
    }
}
