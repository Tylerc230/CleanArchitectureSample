//
//  BLEListViewController.swift
//  CleanArchitectureSample
//
//  Created by Tyler Casselman on 11/30/17.
//  Copyright © 2017 Tyler Casselman. All rights reserved.
//

import UIKit

class BLEListViewController: UIViewController {
    typealias TableChangeSet = BLEListState.TableModel.RowChangeSet
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
        }, completion: nil)
    }
}

extension BLEListViewController: BLEListUI {
    func updateTable(animateChangeSet changeSet: TableChangeSet?) {
        if let changeSet = changeSet {
            animateTableUpdate(with: changeSet)
        } else {
            tableView.reloadData()
        }
    }
}

extension BLEListViewController: UITableViewDelegate {
    
}

extension BLEListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sceneCoordinator?.tableModel.numSections ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sceneCoordinator?.tableModel.numRows(inSection: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = .blue
        return cell
    }
}
