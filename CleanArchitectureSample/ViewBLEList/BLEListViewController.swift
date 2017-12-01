//
//  BLEListViewController.swift
//  CleanArchitectureSample
//
//  Created by Tyler Casselman on 11/30/17.
//  Copyright © 2017 Tyler Casselman. All rights reserved.
//

import UIKit

class BLEListViewController: UIViewController {
    static func instantiateFromStoryboard() -> BLEListViewController {
        let bundle = Bundle(for: self)
        let storyboard =  UIStoryboard(name: "BLEList", bundle: bundle)
        return storyboard.instantiateInitialViewController() as! BLEListViewController
    }
}

extension BLEListViewController: BLEListUI {
    
}
