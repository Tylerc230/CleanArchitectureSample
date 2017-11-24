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

    mutating func append(discoveredBLEDevice device: BLEDevice) {
        bleDevicesInRange.append(device)
    }
    
    private mutating func buildTableModel() {
        var sections: [TableModel.Section] = []
        if !knownDeviceEntries.isEmpty {
            let section = TableModel.Section.known(knownDeviceEntries)
            sections.append(section)
        }
        if !bleDevicesInRange.isEmpty {
            let knownDeviceUUIDs = Set(knownDeviceEntries.map { $0.identifier })
            let unknownDevices = bleDevicesInRange.filter { !knownDeviceUUIDs.contains($0.identifier)}
            let section = TableModel.Section.discovered(unknownDevices)
            sections.append(section)
        }
        tableModel = TableModel(sections: sections)
    }
    
    private struct TableModel {
        enum Section {
            case known([DeviceEntry]), discovered([BLEDevice])
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
