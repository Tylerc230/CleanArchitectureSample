import PlaygroundSupport
@testable import UIPlayground

let bleDeviceManager = StubBLEDeviceManager()
let deviceRepository = InMemoryBLEDeviceRepository()
let flowCoordinator = BLEListFlowCoordinator(deviceManager: bleDeviceManager, deviceRepository: deviceRepository)
DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
    bleDeviceManager.discover(device: BLEDevice(identifier: UUID(), type: "Fake device"))
}


PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = flowCoordinator.rootViewController

