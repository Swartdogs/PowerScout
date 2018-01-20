//
//  SteamGearPlacementType.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/13/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation

enum SteamGearPlacementType : Int {
    case notPlaced = 0, left, center, right
    
    func toString() -> String {
        return (self == .left)   ? "Left"   :
               (self == .center) ? "Center" :
               (self == .right)  ? "Right"  : "Not Placed"
    }
}
