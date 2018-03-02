//
//  StrongDefense.swift
//  PowerScout
//
//  Created by Srinivas Dhanwada on 3/2/18.
//  Copyright © 2018 FRC Team 525. All rights reserved.
//

import Foundation

struct Defense: PropertyListReadable {
    var type:DefenseType = .unknown
    var location:Int = 0
    var timesCrossed:Int = 0
    var failedTimesCrossed:Int = 0
    var timesCrossedWithBall:Int = 0
    var timesAssistedCross:Int = 0
    var autoTimesCrossed:Int = 0
    var autoFailedTimesCrossed:Int = 0
    var autoTimesCrossedWithBall:Int = 0
    var autoTimesAssistedCross:Int = 0
    
    init() {
        
    }
    
    init(withDefenseType type:DefenseType) {
        self.type = type
    }
    
    init?(propertyListRepresentation: NSDictionary?) {
        guard let values = propertyListRepresentation else { return nil }
        if let t = values["type"]   as? Int,
            let l = values["loc"]    as? Int,
            let c = values["cross"]  as? Int,
            let f = values["fcross"] as? Int,
            let b = values["bcross"] as? Int,
            let a = values["across"] as? Int,
            let ac = values["atcross"] as? Int,
            let af = values["afcross"] as? Int,
            let ab = values["abcross"] as? Int,
            let aa = values["aacross"] as? Int {
            self.type = DefenseType(rawValue: t)!
            self.location = l
            self.timesCrossed = c
            self.failedTimesCrossed = f
            self.timesCrossedWithBall = b
            self.timesAssistedCross = a
            self.autoTimesCrossed = ac
            self.autoFailedTimesCrossed = af
            self.autoTimesCrossedWithBall = ab
            self.autoTimesAssistedCross = aa
        }
    }
    
    mutating func clearStats() {
        self.timesCrossed = 0
        self.failedTimesCrossed = 0
        self.timesCrossedWithBall = 0
        self.timesAssistedCross = 0
        self.autoTimesCrossed = 0
        self.autoFailedTimesCrossed = 0
        self.autoTimesCrossedWithBall = 0
        self.autoTimesAssistedCross = 0
    }
    
    func toArray(_ finalResult:ResultType) -> [String] {
        return finalResult == .noShow ? ["Defense \(self.location): \(self.type.toStringResults())",
            "---", "---", "---", "---"] :
            ["Defense \(self.location): \(self.type.toStringResults())",
                "\(self.autoTimesCrossed) | \(self.timesCrossed)",
                "\(self.autoTimesCrossedWithBall) | \(self.timesCrossedWithBall)",
                "\(self.autoFailedTimesCrossed) | \(self.failedTimesCrossed)",
                "\(self.autoTimesAssistedCross) | \(self.timesAssistedCross)"]
    }
    
    func propertyListRepresentation() -> NSDictionary {
        let representation:[String:AnyObject] = ["type":type.rawValue as AnyObject, "loc":location as AnyObject, "cross":timesCrossed as AnyObject, "fcross":failedTimesCrossed as AnyObject, "bcross":timesCrossedWithBall as AnyObject, "across":timesAssistedCross as AnyObject, "atcross":autoTimesCrossed as AnyObject, "afcross":autoFailedTimesCrossed as AnyObject, "abcross":autoTimesCrossedWithBall as AnyObject, "aacross":autoTimesAssistedCross as AnyObject]
        
        return representation as NSDictionary
    }
}
