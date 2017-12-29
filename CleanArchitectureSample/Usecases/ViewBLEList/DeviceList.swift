import Foundation
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
