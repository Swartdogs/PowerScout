//
//  ResultType.swift
//  PowerScout
//
//  Created by Srinivas Dhanwada on 3/2/18.
//  Copyright © 2018 FRC Team 525. All rights reserved.
//

import Foundation

enum ResultType : Int {
    case none = 0, loss, win, tie, noShow
    
    func toString() -> String {
        return (self == .loss) ? "Loss" :
            (self == .win) ? "Win" :
            (self == .tie) ? "Tie" :
            (self == .noShow) ? "No Show" : "N/A"
    }
}
