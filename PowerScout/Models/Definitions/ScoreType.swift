//
//  ScoreType.swift
//  PowerScout
//
//  Created by Srinivas Dhanwada on 3/2/18.
//  Copyright © 2018 FRC Team 525. All rights reserved.
//

import Foundation

enum ScoreType: Int {
    case unknown = 0, missedHigh, high, missedLow, low
    
    var missed:Bool {
        return (self == .missedHigh || self == .missedLow)
    }
    
    func toString() -> String {
        return (self == .high)        ? "Scored High Goal" :
            (self == .low)         ? "Scored Low Goal " :
            (self == .missedHigh)  ? "Missed High Goal" :
            (self == .missedLow)   ? "Missed Low Goal"  : "Unknown"
    }
}
