import PlaygroundSupport
@testable import UIPlayground
struct PlaygroundBLEDeviceManager: BLEDeviceManager {}
struct MockDeviceRepository: BLEDeviceRepository {}
let bleListView = BLEListViewController.instantiateFromStoryboard()
let bleDeviceManager = PlaygroundBLEDeviceManager()
let mockDeviceRepository = MockDeviceRepository()
let bleListSceneCoordinator = BLEListSceneCoordinator(ui: bleListView, bleDeviceManager: bleDeviceManager, deviceRepository: mockDeviceRepository)


PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = bleListView.view
