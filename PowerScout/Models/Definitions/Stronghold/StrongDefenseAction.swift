//
//  StrongDefenseAction.swift
//  PowerScout
//
//  Created by Srinivas Dhanwada on 3/2/18.
//  Copyright © 2018 FRC Team 525. All rights reserved.
//

import Foundation

enum StrongDefenseAction: Int {
    case none = 0, crossed, attemptedCross, crossedWithBall, assistedCross
    
    func toString() -> String {
        return (self == .crossed)         ? "Crossed"             :
            (self == .attemptedCross)  ? "Attempted Cross"     :
            (self == .crossedWithBall) ? "Crossed With Ball"   :
            (self == .assistedCross)   ? "Assisted With Cross" : "None"
    }
}
