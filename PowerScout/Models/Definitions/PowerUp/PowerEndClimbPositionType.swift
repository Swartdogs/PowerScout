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
    case failure
    case assistOther
    case soloClimb
    case assistedClimb
    case climbAndAssistOther
    
    func toString() -> String {
        return (self == .failure)              ? "Failure to Climb" :
               (self == .assistOther)          ? "No climb - but helped another"   :
               (self == .soloClimb)            ? "Climb by themselves"       :
               (self == .assistedClimb)        ? "Climb with help" :
               (self == .climbAndAssistOther)  ? "Climb - helping another team" : "No Attempt";
    }
    
    static let all:[PowerEndClimbPositionType] = [
        .none,
        .failure,
        .assistOther,
        .soloClimb,
        .assistedClimb,
        .climbAndAssistOther
    ]
}
