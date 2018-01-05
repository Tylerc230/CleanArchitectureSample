import Foundation
struct DeviceList {
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
        let allDeviceEntries = deviceEntries + newDeviceEntries
        let deviceEntryIds = Set(allDeviceEntries.map { $0.identifier })
        let allUnknownDevices = unknownDevices + newBLEDevices
        let newUnknownDevices = allUnknownDevices.filter { !deviceEntryIds.contains($0.identifier) }
        discoveredDeviceCache.formUnion(newBLEDevices.map { $0.identifier })
        set(deviceEntries: allDeviceEntries, unknownDevices: newUnknownDevices)
    }
    
    mutating func update(deviceEntries updatedDeviceEntries: [DeviceEntry]) {
        let allDeviceEntries = deviceEntries.map { (entry: DeviceEntry) -> DeviceEntry in
            guard let updatedEntry = updatedDeviceEntries.first(where: {entry.sameDevice(as: $0) }) else {
                return entry
            }
            return updatedEntry
        }
        set(deviceEntries: allDeviceEntries, unknownDevices: unknownDevices)
    }
    
    enum DeviceType {
        case knownDevices([DeviceEntry]), discoveredDevices([BLEDevice])
        func sameType(as other: DeviceType) -> Bool {
            switch (self, other) {
            case (.knownDevices, .knownDevices), (.discoveredDevices, .discoveredDevices):
                return true
            default:
                return false
            }
        }
    }
    
    private var devices = [DeviceType]()
    private var discoveredDeviceCache: Set<UUID> = []
    private var deviceEntries: [DeviceEntry] {
        return devices.flatMap { (deviceType: DeviceType) -> [DeviceEntry] in
            switch deviceType {
            case .knownDevices(let existingDeviceEntries):
                return existingDeviceEntries
            default:
                return []
            }
        }
    }
    
    private var unknownDevices: [BLEDevice] {
        return devices.flatMap { (deviceType: DeviceType) -> [BLEDevice] in
            switch deviceType {
            case .discoveredDevices(let existingBLEDevices):
                return existingBLEDevices
            default:
                return []
            }
        }
    }
    
    private mutating func set(deviceEntries: [DeviceEntry], unknownDevices: [BLEDevice]) {
        devices.removeAll()
        if !deviceEntries.isEmpty {
            devices.append(.knownDevices(deviceEntries))
        }
        
        if !unknownDevices.isEmpty {
            devices.append(.discoveredDevices(unknownDevices))
        }
    }
}

extension DeviceList: Collection {
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
}
