//
//  ActionDatatype.swift
//  PowerScout
//
//  Created by Srinivas Dhanwada on 3/2/18.
//  Copyright © 2018 FRC Team 525. All rights reserved.
//

import Foundation

enum ActionDataType: PropertyListReadable {
    case none
    case penaltyData(PenaltyType)
    
    init?(propertyListRepresentation: NSDictionary?) {
        guard let values = propertyListRepresentation else { return nil }
        
        if let p = values["penalty"] as? Int {
            self = .penaltyData(PenaltyType(rawValue: p)!)
        } else {
            self = .none
        }
    }
    
    func propertyListRepresentation() -> NSDictionary {
        switch self {
        case let .penaltyData(penalty):
            return ["penalty":penalty.rawValue]
        default:
            return ["none":0]
        }
    }
}
