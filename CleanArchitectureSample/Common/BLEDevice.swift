import Foundation
struct BLEDevice {
    let identifier: UUID
}

extension BLEDevice: Equatable {
    public static func ==(lhs: BLEDevice, rhs: BLEDevice) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

extension BLEDevice: Hashable {
    var hashValue: Int {
        return identifier.hashValue
    }
}
