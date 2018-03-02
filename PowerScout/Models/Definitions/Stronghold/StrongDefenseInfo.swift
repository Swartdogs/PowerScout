//
//  StrongDefenseInfo.swift
//  PowerScout
//
//  Created by Srinivas Dhanwada on 3/2/18.
//  Copyright © 2018 FRC Team 525. All rights reserved.
//

import Foundation

struct StrongDefenseInfo: PropertyListReadable {
    var type:StrongDefenseType = .unknown
    var actionPerformed:StrongDefenseAction = .none
    
    init() {
        
    }
    
    init?(propertyListRepresentation: NSDictionary?) {
        guard let values = propertyListRepresentation else { return nil }
        if let t = values["type"] as? Int, let a = values["action"] as? Int {
            self.type = StrongDefenseType(rawValue: t)!
            self.actionPerformed = StrongDefenseAction(rawValue: a)!
        }
    }
    
    func propertyListRepresentation() -> NSDictionary {
        let representation:[String:AnyObject] = ["type":type.rawValue as AnyObject, "action":actionPerformed.rawValue as AnyObject]
        return representation as NSDictionary
    }
}
