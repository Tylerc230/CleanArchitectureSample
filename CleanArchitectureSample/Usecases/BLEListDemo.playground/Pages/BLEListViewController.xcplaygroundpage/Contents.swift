import PlaygroundSupport
@testable import UIPlayground

let viewController = BLEListViewController.instantiateFromStoryboard()
_ = viewController.view
let ui: BLEListUI = viewController
typealias TableViewModel = BLEListState.TableViewModel
//let before = tableView(entryCellNames: ["a", "A", "B"])
//let after = tableView(entryCellNames: ["b", "a", "B", "C"])
let before = tableView(entryCellNames: ["A", "B"])
let after = tableView(entryCellNames: ["B"], unknownTypes: ["device"])
ui.update(tableViewModel: before, animateChangeSet: nil)
DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
    let changeSet = rowChangeSet()
    ui.update(tableViewModel: after, animateChangeSet: changeSet)
}

func rowChangeSet() -> RowChangeSet {
    let insertedRows: [IndexPath] =  []//[IndexPath(row: 0, section:1)]
    let deletedRows: [IndexPath] = []//[IndexPath(row:0, section: 0)]
    let movedRows: [RowChangeSet.Move] = [RowChangeSet.Move(start: IndexPath(row: 0, section:0), end: IndexPath(row: 0, section: 1))]
    let reloadedRows: [IndexPath] = []//[IndexPath(row: 0, section: 1)]
    let deletedSection: IndexSet = []
    let insertedSection: IndexSet = [1]
    return RowChangeSet(reloadedRows: reloadedRows, addedRows: insertedRows, deletedRows: deletedRows, movedRows: movedRows, addedSections: insertedSection, deletedSections: deletedSection)
}
//func rowChangeSet() -> RowChangeSet {
//    let deletedRows: [IndexPath] = []//[IndexPath(row: 0, section:0)]
//    let insertedRows: [IndexPath] = [IndexPath(row: 0, section:0)]
//    //after everything (1 with delete, 2 without delete)
//    let reloadedRows: [IndexPath] = [IndexPath(row: 3, section: 0)]
//    //looks like the start has to be the old index path and the end has to be after the update (with delete its row 1 to row 1)
//    let movedRows = RowChangeSet.Move(start: IndexPath(row: 1, section:0), end: IndexPath(row: 3, section: 0))
//    return RowChangeSet(reloadedRows: reloadedRows, addedRows: insertedRows, deletedRows: deletedRows, movedRows: [movedRows], addedSections: [], deletedSections: [])
//}

func tableView(entryCellNames entryNames: [String] = [], unknownTypes: [String] = []) -> TableViewModel {
    let entries = entryCells(withNames: entryNames)
    let unknown = unknownCells(withTypes: unknownTypes)
    var sections = [[TableViewModel.CellConfig]]()
    if !entries.isEmpty  {
        sections.append(entries)
    }
    if !unknown.isEmpty {
        sections.append(unknown)
    }
    return TableViewModel(sections: sections, sectionTitles: ["My Devices", "Discovere Devices"])
}

func unknownCells(withTypes types: [String]) -> [TableViewModel.CellConfig] {
    return types
        .map { BLEDevice(identifier: UUID(), type: $0) }
        .map { TableViewModel.CellConfig(device: $0)  }
}

func entryCells(withNames names: [String]) -> [TableViewModel.CellConfig] {
    return names
        .map { DeviceEntry(identifier: UUID(), name: $0, type: "") }
        .map { TableViewModel.CellConfig(deviceEntry: $0, inRange: false)  }
}


PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = viewController
