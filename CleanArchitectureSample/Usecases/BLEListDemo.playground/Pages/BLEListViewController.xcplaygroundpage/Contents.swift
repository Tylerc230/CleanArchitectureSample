import PlaygroundSupport
@testable import UIPlayground

let viewController = BLEListViewController.instantiateFromStoryboard()
_ = viewController.view
let ui: BLEListUI = viewController
typealias TableViewModel = BLEListState.TableViewModel
let uuid = UUID()
//let unknownDevice = BLEDevice(identifier: uuid, type: "Some Type")
let beforeCells = entryCells(withNames: ["a", "A", "B"])
let before = TableViewModel(sections: [beforeCells], sectionTitles: ["My Devices"])
let afterCells = entryCells(withNames: ["b", "a", "B", "C"])
let after = TableViewModel(sections: [afterCells], sectionTitles: ["My Devices"])
ui.update(tableViewModel: before, animateChangeSet: nil)
DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
    let deletedRows: [IndexPath] = []//[IndexPath(row: 0, section:0)]
    let insertedRows: [IndexPath] = [IndexPath(row: 0, section:0)]
    //after everything (1 with delete, 2 without delete)
    let reloadedRows: [IndexPath] = [IndexPath(row: 3, section: 0)]
    //looks like the start has to be the old index path and the end has to be after the update (with delete its row 1 to row 1)
    let movedRows = [RowChangeSet.Move(start: IndexPath(row: 1, section:0), end: IndexPath(row: 3, section: 0))]
    let changeSet = RowChangeSet(reloadedRows: reloadedRows, addedRows: insertedRows, deletedRows: deletedRows, movedRows: movedRows, addedSections: [], deletedSections: [])
    ui.update(tableViewModel: after, animateChangeSet: changeSet)
}

func entryCells(withNames names: [String]) -> [TableViewModel.CellConfig] {
    return names
        .map { DeviceEntry(identifier: UUID(), name: $0, type: "") }
        .map { TableViewModel.CellConfig(deviceEntry: $0, inRange: false)  }
}


PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = viewController
