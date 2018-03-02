//
//  PenaltyType.swift
//  PowerScout
//
//  Created by Srinivas Dhanwada on 3/2/18.
//  Copyright © 2018 FRC Team 525. All rights reserved.
//

import Foundation

enum PenaltyType : Int {
    case none = 0, foul, techFoul, yellowCard, redCard
    
    func toString() -> String {
        return self == .foul       ? "Foul"           :
            self == .techFoul   ? "Technical Foul" :
            self == .yellowCard ? "Yellow Card"    :
            self == .redCard    ? "Red Card"       : "None"
    }
}
