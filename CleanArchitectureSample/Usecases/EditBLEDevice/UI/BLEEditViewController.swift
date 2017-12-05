//
//  BLEEditViewController.swift
//  CleanArchitectureSample
//
//  Created by Tyler Casselman on 12/4/17.
//  Copyright © 2017 Tyler Casselman. All rights reserved.
//

import UIKit

class BLEEditViewController: UIViewController {
    static func instatiateFromStoryboard() -> BLEEditViewController {
        let bundle = Bundle(for: self)
        let storyboard = UIStoryboard(name: "BLEList", bundle: bundle)
        return storyboard.instantiateViewController(withIdentifier: "BLEEditViewController") as! BLEEditViewController
    }
}
