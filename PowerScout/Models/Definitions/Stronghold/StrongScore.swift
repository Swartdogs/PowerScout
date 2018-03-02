//
//  StrongScore.swift
//  PowerScout
//
//  Created by Srinivas Dhanwada on 3/2/18.
//  Copyright © 2018 FRC Team 525. All rights reserved.
//

import Foundation

struct StrongScore: PropertyListReadable {
    var type:ScoreType = .unknown
    var location:StrongScoreLocationType = .unknown
    
    init() {
        
    }
    
    init?(propertyListRepresentation: NSDictionary?) {
        guard let values = propertyListRepresentation else { return nil }
        if let t = values["type"] as? Int, let l = values["loc"] as? Int {
            self.type = ScoreType(rawValue: t)!
            self.location = StrongScoreLocationType(rawValue: l)!
        }
    }
    
    func propertyListRepresentation() -> NSDictionary {
        let representation:[String:AnyObject] = ["type":type.rawValue as AnyObject, "loc":location.rawValue as AnyObject]
        return representation as NSDictionary
    }
}
