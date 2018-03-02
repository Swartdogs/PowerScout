//
//  AllianceType.swift
//  PowerScout
//
//  Created by Srinivas Dhanwada on 3/2/18.
//  Copyright © 2018 FRC Team 525. All rights reserved.
//

import Foundation

enum AllianceType : Int {
    case unknown = 0, blue, red
    
    func toString() -> String {
        return (self == .blue) ? "Blue" :
            (self == .red)  ? "Red"  : "Unknown"
    }
}
