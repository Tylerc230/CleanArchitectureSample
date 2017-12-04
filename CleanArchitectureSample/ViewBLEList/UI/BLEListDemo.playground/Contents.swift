import PlaygroundSupport
@testable import UIPlayground

let bleListView = BLEListViewController.instantiateFromStoryboard()
let bleDeviceManager = MockBLEDeviceManager()
let deviceRepository = MockDeviceRepository()
let bleListSceneCoordinator = BLEListSceneCoordinator(ui: bleListView, bleDeviceManager: bleDeviceManager, deviceRepository: deviceRepository)
bleListView.sceneCoordinator = bleListSceneCoordinator
DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
    bleDeviceManager.discover(device: BLEDevice(identifier: UUID(), type: "Fake device"))
}


PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = bleListView

