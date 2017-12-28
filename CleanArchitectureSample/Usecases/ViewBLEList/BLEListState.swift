import Foundation
struct BLEListState {
    private var deviceList = DeviceList()

    private typealias DeviceIndexPathMap = [UUID: IndexPath]
    private (set) var tableModel = TableViewModel(sections: [])
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
    
    mutating func append(deviceEntries: [DeviceEntry] = [], bleDevices: [BLEDevice] = []) -> TableViewModel.RowChangeSet {
        let oldDeviceList = deviceList
        deviceList.append(newDeviceEntries: deviceEntries, newBLEDevices: bleDevices)
        buildTableModel()
        return TableViewModel.RowChangeSet(newDeviceList: deviceList, oldDeviceList: oldDeviceList)
    }
    
    private mutating func buildTableModel() {
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
        tableModel = TableViewModel(sections: sections)
    }
    

    struct DeviceList: Collection {
        typealias Element = DeviceType
        typealias Index = Int
        var startIndex: Index {
            return devices.startIndex
        }
        
        var endIndex: Index {
           return devices.endIndex
        }
        
        subscript(index: Index) -> Element {
            return devices[index]
        }
        
        func index(after i: Index) -> Index {
            return devices.index(after: i)
        }

        private var devices = [DeviceType]()
        private var discoveredDeviceCache: Set<UUID> = []
        var isEmpty: Bool {
            return devices.isEmpty
        }
        
        func devices(at index: Int) -> DeviceType {
            return devices[index]
        }
        
        func isInRange(_ device: DeviceEntry) -> Bool {
            return discoveredDeviceCache.contains(device.identifier)
        }

        mutating func append(newDeviceEntries: [DeviceEntry] = [], newBLEDevices: [BLEDevice] = []) {
            let allDeviceEntries = devices.flatMap { (deviceType: DeviceType) -> [DeviceEntry] in
                switch deviceType {
                case .knownDevices(let existingDeviceEntries):
                    return existingDeviceEntries
                default:
                    return []
                }
            } + newDeviceEntries
            
            
            let allDiscoveredDevices = devices.flatMap { (deviceType: DeviceType) -> [BLEDevice] in
                switch deviceType {
                case .discoveredDevices(let existingBLEDevices):
                    return existingBLEDevices
                default:
                    return []
                }
            } + newBLEDevices
            
            let deviceEntryIds = Set(allDeviceEntries.map { $0.identifier })
            discoveredDeviceCache = Set(allDiscoveredDevices.map { $0.identifier})
            let unknownDevices = allDiscoveredDevices.filter {
                return !deviceEntryIds.contains($0.identifier)
            }
            devices.removeAll()
            if !allDeviceEntries.isEmpty {
                devices.append(.knownDevices(allDeviceEntries))
            }

            if !unknownDevices.isEmpty {
                devices.append(.discoveredDevices(unknownDevices))
            }
        }
        
        enum DeviceType {
            case knownDevices([DeviceEntry]), discoveredDevices([BLEDevice])
        }
    }
    
    enum Transition {
        case newDeviceEntry(BLEDevice)
        case updateDeviceEntry(DeviceEntry)
    }
    
    struct TableViewModel {
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
            init(newDeviceList: DeviceList, oldDeviceList: DeviceList) {
                let newDeviceMap = RowChangeSet.deviceIndexPathMap(for: newDeviceList)
                let oldDeviceMap = RowChangeSet.deviceIndexPathMap(for: oldDeviceList)
                let inserted = RowChangeSet.insertedDevices(newDevices: newDeviceMap, oldDevices: oldDeviceMap)
                let devicesWhichMovedSections = RowChangeSet.movedSections(newDevices: newDeviceMap, oldDevices: oldDeviceMap)
                
                //Need to add the newly inserted rows plus the new positions of the rows which moved sections
                let insertedIndexPaths = inserted
                    .union(devicesWhichMovedSections)
                    .flatMap { newDeviceMap[$0] }
                
                let addedSections = RowChangeSet.sectionsAdded(newDevices: newDeviceMap, oldDevices: oldDeviceMap)
                let deletedIndexPaths = devicesWhichMovedSections.flatMap { oldDeviceMap[$0] }
                self.init(addedRows: insertedIndexPaths, deletedRows: deletedIndexPaths, addedSections: IndexSet(addedSections))
            }
            
            private init(addedRows: [IndexPath], deletedRows: [IndexPath], addedSections: IndexSet) {
                self.addedRows = addedRows
                self.deletedRows = deletedRows
                self.addedSections = addedSections
            }
            
            private static func deviceIndexPathMap(for deviceList: DeviceList) -> DeviceIndexPathMap {
                let idIndexPathPairs: [(UUID, IndexPath)] = deviceList
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
            
            private static func insertedDevices(newDevices: DeviceIndexPathMap, oldDevices: DeviceIndexPathMap) -> Set<UUID> {
                let currentDevices = Set(newDevices.keys)
                let oldDevices = Set(oldDevices.keys)
                return currentDevices.subtracting(oldDevices)
            }
            
            private static func movedSections(newDevices: DeviceIndexPathMap, oldDevices: DeviceIndexPathMap) -> Set<UUID> {
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
            
            private static func sectionsAdded(newDevices: DeviceIndexPathMap, oldDevices: DeviceIndexPathMap) -> IndexSet {
                func sections(from devicePathMap: DeviceIndexPathMap) -> IndexSet {
                    let sections = Set(devicePathMap.values).map { $0.section }
                    return IndexSet(sections)
                }
                let oldSections = sections(from: oldDevices)
                let newSections = sections(from: newDevices)
                return newSections.subtracting(oldSections)
            }
            let addedRows: [IndexPath]
            let deletedRows: [IndexPath]
            let addedSections: IndexSet
        }
        
        private let sections: [[CellConfig]]
    }
}
