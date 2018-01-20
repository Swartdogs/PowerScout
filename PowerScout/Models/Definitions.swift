//
//  Definitions.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 2/13/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import Foundation
import UIKit

// MARK: PropertyListReadable Protocol
protocol PropertyListReadable {
    func propertyListRepresentation() -> NSDictionary
    init?(propertyListRepresentation:NSDictionary?)
}

// MARK: DefenseType
enum DefenseType:Int {
    case unknown = 0, portcullis, chevaldefrise, moat, ramparts, drawbridge, sallyport, rockwall, roughterrain, lowbar
    
    func complementType() -> DefenseType {
        return (self == .portcullis) ? .chevaldefrise :
               (self == .chevaldefrise) ? .portcullis :
               (self == .moat) ? .ramparts :
               (self == .ramparts) ? .moat :
               (self == .drawbridge) ? .sallyport :
               (self == .sallyport) ? .drawbridge :
               (self == .rockwall) ? .roughterrain :
               (self == .roughterrain) ? .rockwall : .unknown
    }
    
    func toString() -> String! {
        return (self == .portcullis) ? "portcullis" :
               (self == .chevaldefrise) ? "chevaldefrise" :
               (self == .moat) ? "moat" :
               (self == .ramparts) ? "ramparts" :
               (self == .drawbridge) ? "drawbridge" :
               (self == .sallyport) ? "sallyport" :
               (self == .rockwall) ? "rockwall" :
               (self == .roughterrain) ? "roughterrain" :
               (self == .lowbar) ? "lowbar" : "unknown"
    }
    
    func toStringResults() -> String {
        return (self == .portcullis) ? "Portcullis" :
            (self == .chevaldefrise) ? "Cheval de Frise" :
            (self == .moat) ? "Moat" :
            (self == .ramparts) ? "Ramparts" :
            (self == .drawbridge) ? "Drawbridge" :
            (self == .sallyport) ? "Sallyport" :
            (self == .rockwall) ? "Rock Wall" :
            (self == .roughterrain) ? "Rough Terrain" :
            (self == .lowbar) ? "Low Bar" : "Unknown"
    }
}

// MARK: ScoreType
enum ScoreType: Int {
    case unknown = 0, missedHigh, high, missedLow, low
    
    var missed:Bool {
        return (self == .missedHigh || self == .missedLow)
    }
    
    func toString() -> String {
        return (self == .high)        ? "Scored High Goal" :
               (self == .low)         ? "Scored Low Goal " :
               (self == .missedHigh)  ? "Missed High Goal" :
               (self == .missedLow)   ? "Missed Low Goal"  : "Unknown"
    }
}

// MARK: ScoreLocation
enum ScoreLocation: Int {
    case unknown = 0, batter, courtyard, defenses
    
    func toString() -> String {
        return (self == .batter)    ? "Batter"    :
               (self == .courtyard) ? "Courtyard" :
               (self == .defenses)  ? "Defenses"  : "Unknown"
    }
}

// MARK: FieldLayoutType
enum FieldLayoutType: Int {
    case blueRed = 0, redBlue
    
    mutating func reverse() {
        self = self == .blueRed ? .redBlue : .blueRed
    }
    
    func getImage() -> UIImage {
        return self == .blueRed ? UIImage(named: "fieldLayoutBlueRed")! : UIImage(named: "fieldLayoutRedBlue")!
    }
}

// MARK: AllianceType
enum AllianceType : Int {
    case unknown = 0, blue, red
    
    func toString() -> String {
        return (self == .blue) ? "Blue" :
               (self == .red)  ? "Red"  : "Unknown"
    }
}

// MARK: ActionType
enum ActionType : Int {
    case unknown = 0, score, defense, penalty
    
    func toString() -> String {
        return (self == .score)   ? "Score"   :
               (self == .defense) ? "Defense" :
               (self == .penalty) ? "Penalty" : "Unknown"
    }
}

// MARK: EditType
enum EditType : Int {
    case delete = 0, add
    
    mutating func reverse() {
        self = self == .delete ? .add : .delete;
    }
}

// MARK: SectionType
enum SectionType : Int {
    case auto = 0, tele
    
    func toString() -> String {
        return (self == .auto) ? "Autonomous" : "Teleop"
    }
}

// MARK: DefenseAction
enum DefenseAction: Int {
    case none = 0, crossed, attemptedCross, crossedWithBall, assistedCross
    
    func toString() -> String {
        return (self == .crossed)         ? "Crossed"             :
               (self == .attemptedCross)  ? "Attempted Cross"     :
               (self == .crossedWithBall) ? "Crossed With Ball"   :
               (self == .assistedCross)   ? "Assisted With Cross" : "None"
    }
}

// MARK: FinalConfigType
enum FinalConfigType : Int {
    case none = 0, climb, climbAttempt
    
    func toString() -> String {
        return (self == .climb) ? "Climb" :
               (self == .climbAttempt) ? "Attempted Climb" : "N/A"
    }
}

// MARK: ResultType
enum ResultType : Int {
    case none = 0, loss, win, tie, noShow
    
    func toString() -> String {
        return (self == .loss) ? "Loss" :
               (self == .win) ? "Win" :
               (self == .tie) ? "Tie" :
               (self == .noShow) ? "No Show" : "N/A"
    }
}

// MARK: UpdateType
enum UpdateType : Int {
    case none = 0, teamInfo, fieldSetup, finalStats, actionsEdited, autonomous, teleop
}

// MARK: PenaltyType
enum PenaltyType : Int {
    case none = 0, foul, techFoul, yellowCard, redCard
    
    func toString() -> String {
        return self == .foul       ? "Foul"           :
               self == .techFoul   ? "Technical Foul" :
               self == .yellowCard ? "Yellow Card"    :
               self == .redCard    ? "Red Card"       : "None"
    }
}

// MARK: RobotState
struct RobotState:OptionSet {
    let rawValue:Int
    
    static let None = RobotState(rawValue:0)
    static let Stalled = RobotState(rawValue: 1 << 0)
    static let Tipped = RobotState(rawValue: 1 << 1)
    
    func toString() -> String {
        switch self.rawValue {
        case RobotState.Stalled.rawValue:
            return "Stalled"
        case RobotState.Tipped.rawValue:
            return "Tipped"
        case RobotState.Tipped.union(.Stalled).rawValue:
            return "Stall+Tip"
        default:
            return "None"
        }
    }
}

// MARK: MatchQueueData
struct MatchQueueData: PropertyListReadable {
    var matchNumber:Int = 0
    var teamNumber:Int = 0
    var alliance:AllianceType = .unknown
    
    init(match:Int, team:Int, alliance:AllianceType) {
        self.matchNumber = match
        self.teamNumber = team
        self.alliance = alliance
    }
    
    init?(propertyListRepresentation: NSDictionary?) {
        guard let values = propertyListRepresentation else { return nil }
        if let m = values["mNum"] as? Int,
           let t = values["tNum"] as? Int,
           let a = values["all"] as? Int {
            self.matchNumber = m
            self.teamNumber = t
            self.alliance = AllianceType(rawValue: a)!
        } else {
            return nil
        }
    }
    
    func propertyListRepresentation() -> NSDictionary {
        return ["mNum":matchNumber, "tNum":teamNumber, "all":alliance.rawValue]
    }
}

// MARK: Defense
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

// MARK: Score
struct Score: PropertyListReadable {
    var type:ScoreType = .unknown
    var location:ScoreLocation = .unknown
    
    init() {
        
    }
    
    init?(propertyListRepresentation: NSDictionary?) {
        guard let values = propertyListRepresentation else { return nil }
        if let t = values["type"] as? Int, let l = values["loc"] as? Int {
            self.type = ScoreType(rawValue: t)!
            self.location = ScoreLocation(rawValue: l)!
        }
    }
    
    func propertyListRepresentation() -> NSDictionary {
        let representation:[String:AnyObject] = ["type":type.rawValue as AnyObject, "loc":location.rawValue as AnyObject]
        return representation as NSDictionary
    }
}

// MARK: DefenseInfo
struct DefenseInfo: PropertyListReadable {
    var type:DefenseType = .unknown
    var actionPerformed:DefenseAction = .none
    
    init() {
    
    }
    
    init?(propertyListRepresentation: NSDictionary?) {
        guard let values = propertyListRepresentation else { return nil }
        if let t = values["type"] as? Int, let a = values["action"] as? Int {
            self.type = DefenseType(rawValue: t)!
            self.actionPerformed = DefenseAction(rawValue: a)!
        }
    }
    
    func propertyListRepresentation() -> NSDictionary {
        let representation:[String:AnyObject] = ["type":type.rawValue as AnyObject, "action":actionPerformed.rawValue as AnyObject]
        return representation as NSDictionary
    }
}

// MARK: ActionData
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

// MARK: Action
struct Action: PropertyListReadable {
    var section:SectionType = .tele
    var type:ActionType = .unknown
    var data:ActionData = .none
    
    init() {}
    
    init?(propertyListRepresentation: NSDictionary?) {
        guard let values = propertyListRepresentation else { return nil }
        if let t = values["type"] as? Int,
           let s = values["section"] as? Int,
           let d = values["data"] as? NSDictionary {
            self.type = ActionType(rawValue: t)!
            self.section = SectionType(rawValue: s)!
            self.data = ActionData(propertyListRepresentation: d)!
        }
    }
    
    func propertyListRepresentation() -> NSDictionary {
        return ["type":type.rawValue, "section":section.rawValue, "data":data.propertyListRepresentation()]
    }
}

// MARK: ActionEdit
struct ActionEdit {
    var action:Action
    var index:Int
    var edit:EditType
    
    init(edit:EditType, action:Action, atIndex index:Int) {
        self.edit = edit
        self.action = action
        self.index = index
    }
}

// MARK: Stack
struct Stack<Element> {
    fileprivate var items = [Element]()
    fileprivate var limit:Int
    
    init(limit:Int) {
        self.limit = limit
    }
    
    mutating func push(_ item:Element) {
        if items.count == limit {
            items.removeFirst()
        }
        items.append(item)
    }
    
    mutating func pop() -> Element {
        return items.removeLast()
    }
    
    func peek() -> Element? {
        return items.last
    }
    
    func size() -> Int {
        return items.count
    }
    
    mutating func clearAll() {
        items.removeAll()
    }
}
