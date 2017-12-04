//
//  InRangeCell.swift
//  CleanArchitectureSample
//
//  Created by Tyler Casselman on 12/3/17.
//  Copyright © 2017 Tyler Casselman. All rights reserved.
//

import UIKit

class InRangeCell: UITableViewCell {
    @IBOutlet var deviceTypeLabel: UILabel!
    
    static var identifier: String {
        return String(describing: self)
    }
    
    var deviceType: String = "" {
        didSet {
            deviceTypeLabel.text = deviceType
        }
    }
}
