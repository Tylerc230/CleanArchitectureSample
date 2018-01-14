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
    
    mutating func remove(deviceEntries: [DeviceEntry]) {
        let newDeviceEntries = self.deviceEntries.filter {
            return !deviceEntries.contains($0)
        }
        set(deviceEntries: newDeviceEntries, unknownDevices: [])
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
        
        var deviceIdentifiers: [UUID] {
            switch self {
            case .knownDevices(let entries):
                return entries.map { $0.identifier }
            case .discoveredDevices(let devices):
                return devices.map { $0.identifier }
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
            let sorted = sort(deviceEntries: deviceEntries)
            devices.append(.knownDevices(sorted))
        }
        
        if !unknownDevices.isEmpty {
            devices.append(.discoveredDevices(unknownDevices))
        }
    }
    
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
