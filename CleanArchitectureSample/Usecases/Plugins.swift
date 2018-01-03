//
//  Plugins.swift
//  CleanArchitectureSample
//
//  Created by Tyler Casselman on 12/9/17.
//  Copyright © 2017 Tyler Casselman. All rights reserved.
//

import Foundation

protocol BLEDeviceManager: class {
    weak var observer: BLEDeviceManagerObserver? { get set }
}

protocol BLEDeviceManagerObserver: class {
    func didDiscover(device: BLEDevice)
}

protocol BLEDeviceRepository {
    func fetchAllDevices() -> [DeviceEntry]
    func create(deviceEntry: DeviceEntry)
    func update(deviceEntry: DeviceEntry)
}
