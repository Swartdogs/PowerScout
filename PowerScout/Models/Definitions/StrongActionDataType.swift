//
//  StrongActionDataType.swift
//  PowerScout
//
//  Created by Srinivas Dhanwada on 3/2/18.
//  Copyright © 2018 FRC Team 525. All rights reserved.
//

import Foundation

enum ActionData: PropertyListReadable {
    case none
    case scoreData(Score)
    case defenseData(DefenseInfo)
    case penaltyData(PenaltyType)
    
    init?(propertyListRepresentation: NSDictionary?) {
        guard let values = propertyListRepresentation else { return nil }
        if let s = values["score"] as? NSDictionary {
            self = ActionData.scoreData(Score(propertyListRepresentation: s)!)
        } else if let d = values["defense"] as? NSDictionary {
            self = .defenseData(DefenseInfo(propertyListRepresentation: d)!)
        } else if let p = values["penalty"] as? Int {
            self = .penaltyData(PenaltyType(rawValue: p)!)
        } else {
            self = .none
        }
    }
    
    func propertyListRepresentation() -> NSDictionary {
        switch self {
        case let .scoreData(score):
            return ["score":score.propertyListRepresentation()]
        case let .defenseData(defense):
            return ["defense":defense.propertyListRepresentation()]
        case let .penaltyData(penalty):
            return ["penalty":penalty.rawValue]
        default:
            return ["none":0]
        }
    }
}
