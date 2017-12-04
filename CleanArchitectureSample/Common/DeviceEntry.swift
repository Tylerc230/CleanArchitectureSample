import Foundation
struct DeviceEntry {
    let identifier: UUID
    let name: String
    let type: String
}

extension DeviceEntry: Equatable {
    public static func ==(lhs: DeviceEntry, rhs: DeviceEntry) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

extension DeviceEntry: Hashable {
    var hashValue: Int {
        return identifier.hashValue
    }
}
