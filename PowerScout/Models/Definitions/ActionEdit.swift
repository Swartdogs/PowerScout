//
//  ActionEdit.swift
//  PowerScout
//
//  Created by Srinivas Dhanwada on 3/2/18.
//  Copyright © 2018 FRC Team 525. All rights reserved.
//

import Foundation

struct ActionEdit {
    var action:Action
    var index:Int
    var edit:EditType
    
    init(edit:EditType, action:Action, atIndex index:Int) {
        self.edit = edit
        self.action = action
        self.index = index
    }
}

