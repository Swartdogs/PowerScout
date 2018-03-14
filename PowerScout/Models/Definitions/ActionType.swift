//
//  ActionType.swift
//  PowerScout
//
//  Created by Srinivas Dhanwada on 3/2/18.
//  Copyright © 2018 FRC Team 525. All rights reserved.
//

import Foundation

enum ActionType : Int {
    case unknown = 0, score, defense, penalty
    
    func toString() -> String {
        return (self == .score)   ? "Score"   :
            (self == .defense) ? "Defense" :
            (self == .penalty) ? "Penalty" : "Unknown"
    }
}
