import Foundation
struct BLEListState {
    private var deviceList = DeviceList()
    var showNoDevicesCopy: Bool {
        return deviceList.isEmpty
    }
    
    func didSelectRow(at indexPath: IndexPath) -> Transition {
        switch deviceList.devices(at: indexPath.section) {
        case .knownDevices(let deviceEntries):
            return .updateDeviceEntry(deviceEntries[indexPath.row])
        case .discoveredDevices(let bleDevices):
            return .newDeviceEntry(bleDevices[indexPath.row])
        }
    }
    
    mutating func append(deviceEntries: [DeviceEntry] = [], bleDevices: [BLEDevice] = []) {
        deviceList.append(newDeviceEntries: deviceEntries, newBLEDevices: bleDevices)
    }
    
    mutating func remove(deviceEntries: [DeviceEntry]) {
        deviceList.remove(deviceEntries: deviceEntries)
    }
    
    mutating func update(deviceEntries: [DeviceEntry]) {
        deviceList.update(deviceEntries: deviceEntries)
    }
    
    mutating func tableViewAndChangeSet(for updates: (inout BLEListState) -> ()) -> (TableViewModel, RowChangeSet) {
        let oldDeviceList = deviceList
        updates(&self)
        let changeSet = RowChangeSetComputation(newDeviceList: deviceList, oldDeviceList: oldDeviceList).changeSet
        return (tableViewModel, changeSet)
    }
    
    var tableViewModel: TableViewModel {
        let sections: [[TableViewModel.CellConfig]] = deviceList.map {
            switch $0 {
            case .knownDevices(let deviceEntries):
                return deviceEntries.map {
                    let inRange = deviceList.isInRange($0)
                    return TableViewModel.CellConfig(deviceEntry: $0, inRange: inRange)
                }
            case  .discoveredDevices(let unknownDevices):
                return unknownDevices.map {
                    return TableViewModel.CellConfig(device: $0)
                }
            }
        }
        let sectionTitles: [String] = deviceList.map {
            switch $0 {
            case .knownDevices:
                return "My Devices"
            case .discoveredDevices:
                return "Discovered Devices"
            }
        }
        return TableViewModel(sections: sections, sectionTitles: sectionTitles)
    }

    enum Transition {
        case newDeviceEntry(BLEDevice)
        case updateDeviceEntry(DeviceEntry)
    }
    
    struct TableViewModel {
        init(sections: [[CellConfig]] = [], sectionTitles: [String] = []) {
            self.sections = sections
            self.sectionTitles = sectionTitles
        }
        
        var numSections: Int {
            return sections.count
        }
        
        func sectionTitle(at index: Int) -> String {
            return sectionTitles[index]
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
        

        private let sections: [[CellConfig]]
        private let sectionTitles: [String]
    }
}
