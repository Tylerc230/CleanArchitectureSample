import PlaygroundSupport
@testable import UIPlayground

let bleDeviceManager = StubBLEDeviceManager()
let deviceRepository = InMemoryBLEDeviceRepository(devices: [])
let flowCoordinator = BLEListFlowCoordinator(deviceManager: bleDeviceManager, deviceRepository: deviceRepository)
let discovered = BLEDevice(identifier: UUID(), type: "Fake device")
let entry = DeviceEntry(identifier: discovered.identifier, name: "name", type: "")
bleDeviceManager.discover(device: discovered)
deviceRepository.create(deviceEntry: entry)

DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
    deviceRepository.
}


PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = flowCoordinator.rootViewController
