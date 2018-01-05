import PlaygroundSupport
@testable import UIPlayground

let viewController = BLEListViewController.instantiateFromStoryboard()
_ = viewController.view
let ui: BLEListUI = viewController
typealias TableViewModel = BLEListState.TableViewModel
let uuid = UUID()
let unknownDevice = BLEDevice(identifier: uuid, type: "Some Type")
let tableViewModel = TableViewModel(sections: [[TableViewModel.CellConfig(device: unknownDevice)]], sectionTitles: ["Discovered Devices"])
ui.update(tableViewModel: tableViewModel, animateChangeSet: nil)
DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
    let deviceEntry = DeviceEntry(identifier: uuid, name: "Known device", type: "Some Type")
    let tableViewModel = TableViewModel(sections: [[TableViewModel.CellConfig(deviceEntry: deviceEntry, inRange: true)]], sectionTitles: ["My Devices"])
    let changeSet = RowChangeSet(reloadedRows: [], addedRows: [], deletedRows: [], addedSections: [], reloadedSections: [0], deletedSections: [])
    ui.update(tableViewModel: tableViewModel, animateChangeSet: nil)
}


PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = viewController
