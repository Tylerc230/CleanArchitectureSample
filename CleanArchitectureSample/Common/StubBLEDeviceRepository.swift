//
//  MockBLEDeviceRepository.swift
//  CleanArchitectureSample
//
//  Created by Tyler Casselman on 12/3/17.
//  Copyright © 2017 Tyler Casselman. All rights reserved.
//

import Foundation
class StubDeviceRepository: BLEDeviceRepository {
    func fetchAllDevices() -> [DeviceEntry] {
        return (0..<3).map { DeviceEntry(identifier: UUID(), name: "Device \($0 + 1)", type: "Fake device") }
    }
}
