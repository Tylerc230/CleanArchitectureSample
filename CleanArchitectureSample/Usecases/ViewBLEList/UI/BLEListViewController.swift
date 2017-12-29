//
//  BLEListViewController.swift
//  CleanArchitectureSample
//
//  Created by Tyler Casselman on 11/30/17.
//  Copyright © 2017 Tyler Casselman. All rights reserved.
//

import UIKit

class BLEListViewController: UIViewController {
    var tableViewModel = BLEListState.TableViewModel()
    typealias TableChangeSet = BLEListState.TableViewModel.RowChangeSet
    @IBOutlet var tableView: UITableView!
    var sceneCoordinator: BLEListSceneCoordinator?
    static func instantiateFromStoryboard() -> BLEListViewController {
        let bundle = Bundle(for: self)
        let storyboard =  UIStoryboard(name: "BLEList", bundle: bundle)
        return storyboard.instantiateInitialViewController() as! BLEListViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneCoordinator?.viewDidLoad()
    }
    
    private func animateTableUpdate(with changeSet: TableChangeSet) {
        tableView.performBatchUpdates({
            tableView.insertRows(at: changeSet.addedRows, with: .fade)
            tableView.deleteRows(at: changeSet.deletedRows, with: .fade)
            tableView.insertSections(changeSet.addedSections, with: .fade)
        }, completion: nil)
    }
}

extension BLEListViewController: BLEListUI {
    func update(tableViewModel: BLEListState.TableViewModel, animateChangeSet changeSet: BLEListState.TableViewModel.RowChangeSet?) {
        self.tableViewModel = tableViewModel
        guard let changeSet = changeSet else {
            tableView.reloadData()
            return
        }
        animateTableUpdate(with: changeSet)
    }
}

extension BLEListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sceneCoordinator?.indexPathSelected(indexPath)
    }
}

extension BLEListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewModel.numSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewModel.numRows(inSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let config = tableViewModel.cellConfig(at: indexPath)
        switch config {
        case .known(let name, let type, let inRange):
            let cell = tableView.dequeueReusableCell(withIdentifier: KnownDeviceCell.identifier) as! KnownDeviceCell
            cell.set(name: name, type: type)
            cell.isInRange = inRange
            return cell
        case .discovered(let type):
            let cell = tableView.dequeueReusableCell(withIdentifier: InRangeCell.identifier) as! InRangeCell
            cell.deviceType = type
            return cell
        }
    }
}
