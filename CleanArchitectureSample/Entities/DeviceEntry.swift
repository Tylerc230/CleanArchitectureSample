import Foundation
struct DeviceEntry {
    let identifier: UUID
    let name: String
    let type: String
    func sameDevice(as other: DeviceEntry) -> Bool {
        return identifier == other.identifier
    }
}

extension DeviceEntry: Equatable {
    public static func ==(lhs: DeviceEntry, rhs: DeviceEntry) -> Bool {
        return lhs.identifier == rhs.identifier && lhs.name == rhs.name && lhs.type == rhs.type
    }
}

extension DeviceEntry: Hashable {
    var hashValue: Int {
        return identifier.hashValue ^ name.hashValue ^ type.hashValue
    }
}

