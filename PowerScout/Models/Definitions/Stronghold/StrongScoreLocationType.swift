//
//  StrongScoreLocationType.swift
//  PowerScout
//
//  Created by Srinivas Dhanwada on 3/2/18.
//  Copyright © 2018 FRC Team 525. All rights reserved.
//

import Foundation

enum StrongScoreLocationType: Int {
    case unknown = 0, batter, courtyard, defenses
    
    func toString() -> String {
        return (self == .batter)    ? "Batter"    :
            (self == .courtyard) ? "Courtyard" :
            (self == .defenses)  ? "Defenses"  : "Unknown"
    }
}
