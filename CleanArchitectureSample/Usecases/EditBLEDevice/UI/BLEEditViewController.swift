//
//  BLEEditViewController.swift
//  CleanArchitectureSample
//
//  Created by Tyler Casselman on 12/4/17.
//  Copyright © 2017 Tyler Casselman. All rights reserved.
//

import UIKit

class BLEEditViewController: UIViewController {
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var textField: UITextField!
    var sceneCoordinator: BLEEditSceneCoordinator? 
    
    @IBAction func saveTapped() {
        sceneCoordinator?.saveTapped()
    }
    
    static func instatiateFromStoryboard() -> BLEEditViewController {
        let bundle = Bundle(for: self)
        let storyboard = UIStoryboard(name: "BLEList", bundle: bundle)
        return storyboard.instantiateViewController(withIdentifier: "BLEEditViewController") as! BLEEditViewController
    }
}

extension BLEEditViewController: BLEEditUI {
    func set(textFieldText: String) {
        textField.text = textFieldText
    }
    
    func enableSaveButton(_ enable: Bool) {
        navigationItem.leftBarButtonItem?.isEnabled = enable
    }
}
