import Foundation
struct BLEListState {
    private var bleDevicesInRange: [BLEDevice] = [] {
        didSet {
            buildTableModel()
        }
    }
    var knownDeviceEntries: [DeviceEntry] = [] {
        didSet {
            buildTableModel()
        }
    }
    private var tableModel = TableModel(sections: [])
    var showNoDevicesCopy: Bool {
        return bleDevicesInRange.isEmpty
    }
    
    var numSectionsInList: Int {
        return tableModel.sections.count
    }

    func numRows(inSection section: Int) -> Int {
        return tableModel.numRows(inSection: section)
    }
    
    func knownDeviceRow(at index: Int) -> KnownDeviceRow {
        guard case let .known(rows) = tableModel.sections[0] else {
            fatalError()
        }
        return rows[index]
    }
    
    func discoveredDeviceRow(at index: Int) -> DiscoveredDeviceRow {
        guard case let .discovered(rows) = tableModel.sections[1] else {
            fatalError()
        }
        return rows[index]
    }
    
    mutating func append(discoveredBLEDevice device: BLEDevice) {
        bleDevicesInRange.append(device)
    }
    
    private mutating func buildTableModel() {
        var sections: [TableModel.Section] = []
        if !knownDeviceEntries.isEmpty {
            let discoveredDeviceUUIDs = Set(bleDevicesInRange.map { $0.identifier })
            let section = TableModel.Section.known(knownDeviceEntries.map(self.knownDeviceRow(discoveredDeviceIds: discoveredDeviceUUIDs)))
            sections.append(section)
        }
        if !bleDevicesInRange.isEmpty {
            let knownDeviceUUIDs = Set(knownDeviceEntries.map { $0.identifier })
            let unknownDevices = bleDevicesInRange.filter { !knownDeviceUUIDs.contains($0.identifier)}
            let section = TableModel.Section.discovered(unknownDevices.map(self.discoveredDeviceRow))
            sections.append(section)
        }
        tableModel = TableModel(sections: sections)
    }
    
    private func knownDeviceRow(discoveredDeviceIds: Set<UUID>) -> (DeviceEntry) -> KnownDeviceRow {
        return { device in
            let inRange = discoveredDeviceIds.contains(device.identifier)
            return KnownDeviceRow(inRange: inRange)
        }
    }
    
    private func discoveredDeviceRow(from device: BLEDevice) -> DiscoveredDeviceRow {
        return DiscoveredDeviceRow()
    }
    
    struct KnownDeviceRow {
        let inRange: Bool
    }
    
    struct DiscoveredDeviceRow {
        
    }
    
    private struct TableModel {
        enum Section {
            case known([KnownDeviceRow]), discovered([DiscoveredDeviceRow])
        }
        let sections: [Section]
        func numRows(inSection sectionIndex: Int) -> Int {
            switch sections[sectionIndex] {
            case .known(let rows):
                return rows.count
            case .discovered(let rows):
                return rows.count
            }
        }
    }
}
