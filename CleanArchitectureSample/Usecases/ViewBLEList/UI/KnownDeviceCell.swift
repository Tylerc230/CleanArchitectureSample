//
//  KnownDeviceCell.swift
//  CleanArchitectureSample
//
//  Created by Tyler Casselman on 12/3/17.
//  Copyright © 2017 Tyler Casselman. All rights reserved.
//

import UIKit

class KnownDeviceCell: UITableViewCell {
    @IBOutlet var deviceNameLabel: UILabel!
    @IBOutlet var deviceTypeLabel: UILabel!
    @IBOutlet var inRangeIndicator: UIView!
    static var identifier: String {
        return String(describing: self)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        inRangeIndicator.layer.cornerRadius = inRangeIndicator.frame.width/2.0
        inRangeIndicator.layer.masksToBounds = true
    }
    
    var isInRange: Bool = false {
        didSet {
            inRangeIndicator.backgroundColor = isInRange ? .green : .red
        }
    }
    
    func set(name: String, type: String) {
        deviceNameLabel.text = name
        deviceTypeLabel.text = type
    }
    
}
