import Foundation
struct BLEDevice {
    let identifier: UUID
    let type: String
}

extension BLEDevice: Equatable {
    public static func ==(lhs: BLEDevice, rhs: BLEDevice) -> Bool {
        return lhs.identifier == rhs.identifier && lhs.type == rhs.type
    }
}

extension BLEDevice: Hashable {
    var hashValue: Int {
        return identifier.hashValue ^ type.hashValue
    }
}

