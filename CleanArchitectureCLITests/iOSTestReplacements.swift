//
//  iOSTestReplacements.swift
//  CleanArchitectureCLITests
//
//  Created by Tyler Casselman on 11/28/17.
//  Copyright © 2017 Tyler Casselman. All rights reserved.
//

import Foundation
extension IndexPath {
    init(row: Int, section: Int) {
        self.init(indexes: [section, row])
    }
    
    var section: Int {
        return self[0]
    }
    
    var row: Int {
        return self[1]
    }
}
