import Foundation
struct DeviceList {
    var isEmpty: Bool {
        return sections.isEmpty
    }
    
    init(sections: [DeviceSection] = [], inRangeDevices: [BLEDevice] = []) {
        self.sections = sections
        discoveredDeviceCache = Set(inRangeDevices.map { $0.identifier })
    }
    
    func devices(at index: Int) -> DeviceSection {
        return sections[index]
    }
    
    func isInRange(_ device: DeviceEntry) -> Bool {
        return discoveredDeviceCache.contains(device.identifier)
    }
    
    func indexPath(for identifier: UUID) -> IndexPath? {
        return enumerated()
            .flatMap { (sectionIndex, section) -> [IndexPath] in
                switch section {
                case .knownDevices(let devices):
                    return devices
                        .enumerated()
                        .flatMap { args -> IndexPath? in
                            let (deviceIndex, device) = args
                            return device.identifier == identifier ? IndexPath(row: deviceIndex, section: sectionIndex) : nil
                    }
                    
                case .discoveredDevices(let devices):
                    return devices
                        .enumerated()
                        .flatMap { args -> IndexPath? in
                            let (deviceIndex, device) = args
                            return device.identifier == identifier ? IndexPath(row: deviceIndex, section: sectionIndex) : nil
                    }
                }
            }
            .first
    }
    
    enum DeviceSection {
        case knownDevices([DeviceEntry]), discoveredDevices([BLEDevice])
    }
    
    var allDeviceIdentifiers: Set<UUID> {
        let identifiers = flatMap { section -> [UUID] in
            switch section {
            case .knownDevices(let devices):
                return devices.map { $0.identifier }
            case .discoveredDevices(let devices):
                return devices.map { $0.identifier }
            }
        }
        return Set(identifiers)
    }
    
    private var sections = [DeviceSection]()
    private var discoveredDeviceCache: Set<UUID> = []

    private func sort(deviceEntries: [DeviceEntry]) -> [DeviceEntry] {
        let inRangeDevices = deviceEntries
            .filter(self.isInRange)
            .sorted { $0.name < $1.name }
        let outOfRange = deviceEntries
            .filter { !self.isInRange($0) }
            .sorted { $0.name < $1.name }
        return inRangeDevices + outOfRange
    }
}

extension DeviceList: Collection {
    typealias Element = DeviceSection
    typealias Index = Int
    var startIndex: Index {
        return sections.startIndex
    }
    
    var endIndex: Index {
        return sections.endIndex
    }
    
    subscript(index: Index) -> Element {
        return sections[index]
    }
    
    func index(after i: Index) -> Index {
        return sections.index(after: i)
    }
}
