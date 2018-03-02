//
//  EditType.swift
//  PowerScout
//
//  Created by Srinivas Dhanwada on 3/2/18.
//  Copyright © 2018 FRC Team 525. All rights reserved.
//

import Foundation

enum EditType : Int {
    case delete = 0, add
    
    mutating func reverse() {
        self = self == .delete ? .add : .delete;
    }
}
