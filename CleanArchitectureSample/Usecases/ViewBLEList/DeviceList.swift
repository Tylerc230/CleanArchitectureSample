import Foundation
struct DeviceList {
    var isEmpty: Bool {
        return sections.isEmpty
    }
    
    init(sections: [DeviceSection] = [], inRangeDevices: Set<UUID> = []) {
        self.sections = sections
        discoveredDevices = inRangeDevices
    }
    
    func devices(at index: Int) -> DeviceSection {
        return sections[index]
    }
    
    func isInRange(_ device: DeviceEntry) -> Bool {
        return discoveredDevices.contains(device.identifier)
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
    
    func index(for sectionToTest: DeviceSection) -> Int? {
        return enumerated()
            .flatMap { (sectionIndex, section) in
                switch (section, sectionToTest) {
                case (.knownDevices, .knownDevices), (.discoveredDevices, .discoveredDevices):
                    return sectionIndex
                default:
                    return nil
                    
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
    
    private let sections: [DeviceSection]
    let discoveredDevices: Set<UUID>

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
