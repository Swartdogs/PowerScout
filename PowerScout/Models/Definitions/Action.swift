//
//  Action.swift
//  PowerScout
//
//  Created by Srinivas Dhanwada on 3/2/18.
//  Copyright © 2018 FRC Team 525. All rights reserved.
//

import Foundation

struct Action: PropertyListReadable {
    var section: SectionType = .tele
    var type: ActionType = .unknown
    var data: ActionDataType = .none
    
    init() {}
    
    init?(propertyListRepresentation: NSDictionary?) {
        guard let values = propertyListRepresentation else { return nil }
        if let t = values["type"] as? Int,
            let s = values["section"] as? Int,
            let d = values["data"] as? NSDictionary {
            self.type = ActionType(rawValue: t)!
            self.section = SectionType(rawValue: s)!
            self.data = ActionDataType(propertyListRepresentation: d)!
        }
    }
    
    func propertyListRepresentation() -> NSDictionary {
        return ["type":type.rawValue, "section":section.rawValue, "data":data.propertyListRepresentation()]
    }
}
