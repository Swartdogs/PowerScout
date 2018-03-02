//
//  RobotState.swift
//  PowerScout
//
//  Created by Srinivas Dhanwada on 3/2/18.
//  Copyright © 2018 FRC Team 525. All rights reserved.
//

import Foundation

struct RobotState:OptionSet {
    let rawValue:Int
    
    static let None = RobotState(rawValue:0)
    static let Stalled = RobotState(rawValue: 1 << 0)
    static let Tipped = RobotState(rawValue: 1 << 1)
    
    func toString() -> String {
        switch self.rawValue {
        case RobotState.Stalled.rawValue:
            return "Stalled"
        case RobotState.Tipped.rawValue:
            return "Tipped"
        case RobotState.Tipped.union(.Stalled).rawValue:
            return "Stall+Tip"
        default:
            return "Normal"
        }
    }
}
