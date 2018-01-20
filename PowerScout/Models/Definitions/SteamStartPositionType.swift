//
//  SteamStartPositionType.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/13/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation

enum SteamStartPositionType : Int {
    case none = 0, feeder, center, boiler
    
    func toString() -> String {
        return (self == .feeder) ? "Feeder" :
               (self == .center) ? "Center" :
               (self == .boiler) ? "Boiler" : "None";
    }
}
