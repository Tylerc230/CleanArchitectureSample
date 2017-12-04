import PlaygroundSupport
@testable import UIPlayground

struct MockBLEDeviceManager: BLEDeviceManager {}
struct MockDeviceRepository: BLEDeviceRepository {
    func fetchAllDevices() -> [DeviceEntry] {
        return (0..<3).map { DeviceEntry(identifier: UUID(), name: "Device \($0 + 1)") }
    }
}
let bleListView = BLEListViewController.instantiateFromStoryboard()
let bleDeviceManager = MockBLEDeviceManager()
let deviceRepository = MockDeviceRepository()
let bleListSceneCoordinator = BLEListSceneCoordinator(ui: bleListView, bleDeviceManager: bleDeviceManager, deviceRepository: deviceRepository)
bleListView.sceneCoordinator = bleListSceneCoordinator


PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = bleListView

