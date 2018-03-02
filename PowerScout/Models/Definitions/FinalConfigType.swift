//
//  FinalConfigType.swift
//  PowerScout
//
//  Created by Srinivas Dhanwada on 3/2/18.
//  Copyright © 2018 FRC Team 525. All rights reserved.
//

import Foundation

enum FinalConfigType : Int {
    case none = 0, climb, climbAttempt
    
    func toString() -> String {
        return (self == .climb) ? "Climb" :
            (self == .climbAttempt) ? "Attempted Climb" : "N/A"
    }
}
