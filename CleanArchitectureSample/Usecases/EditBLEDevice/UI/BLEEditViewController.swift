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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneCoordinator?.viewDidLoad()
    }
    
    @IBAction func saveTapped() {
        sceneCoordinator?.saveTapped()
    }
    
    @IBAction func nameTextChanged() {
        guard let text = textField.text else {
            return
        }
        sceneCoordinator?.textFieldDidUpdate(with: text)
    }
    
    static func instatiateFromStoryboard() -> BLEEditViewController {
        let bundle = Bundle(for: self)
        let storyboard = UIStoryboard(name: "BLEList", bundle: bundle)
        return storyboard.instantiateViewController(withIdentifier: "BLEEditViewController") as! BLEEditViewController
    }
}

extension BLEEditViewController: BLEEditUI {
    func set(saveButtonText: String) {
        navigationItem.rightBarButtonItem?.title = saveButtonText
    }
    
    func set(deviceType: String) {
        typeLabel.text = deviceType
    }
    
    func set(placeholderText: String) {
        textField.placeholder = placeholderText
    }
    
    func set(textFieldText: String) {
        textField.text = textFieldText
    }
    
    func enableSaveButton(_ enable: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = enable
    }
}

