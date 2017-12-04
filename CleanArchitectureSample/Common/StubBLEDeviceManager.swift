//
//  MockBLEDeviceManager.swift
//  CleanArchitectureSample
//
//  Created by Tyler Casselman on 12/3/17.
//  Copyright © 2017 Tyler Casselman. All rights reserved.
//

import Foundation
class StubBLEDeviceManager: BLEDeviceManager {
    var observer: BLEDeviceManagerObserver?
    func discover(device: BLEDevice) {
        observer?.didDiscover(device: device)
    }
}

