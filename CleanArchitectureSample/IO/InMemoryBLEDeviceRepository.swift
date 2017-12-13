//
//  InMemoryBLEDeviceRepository.swift
//  CleanArchitectureSample
//
//  Created by Tyler Casselman on 12/12/17.
//  Copyright © 2017 Tyler Casselman. All rights reserved.
//

import Foundation
class InMemoryBLEDeviceRepository {
    var devices: [DeviceEntry] = []
}

extension InMemoryBLEDeviceRepository: BLEDeviceRepository {
    func fetchAllDevices() -> [DeviceEntry] {
        return devices
    }
    
    func save(device: DeviceEntry) {
        devices.append(device)
    }
}