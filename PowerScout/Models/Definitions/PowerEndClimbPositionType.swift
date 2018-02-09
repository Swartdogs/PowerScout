//
//  PowerEndClimbPositionType.swift
//  PowerScout
//
//  Created by Srinivas Dhanwada on 2/5/18.
//  Copyright © 2018 FRC Team 525. All rights reserved.
//

import Foundation

enum PowerEndClimbPositionType: Int {
    case none = 0
    case assistOther
    case soloClimb
    case assistedClimb
    case soloClimbAssistOther
    
    func toString() -> String {
        return (self == .assistOther)          ? "Assisted Other"  :
               (self == .soloClimb)            ? "Solo Climb"      :
               (self == .assistedClimb)        ? "Climb with Assistance" :
               (self == .soloClimbAssistOther) ? "Climb and Assisted Other" : "None";
    }
}
