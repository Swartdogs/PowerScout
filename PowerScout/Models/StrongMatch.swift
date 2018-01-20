//
//  StrongMatch.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 2/6/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit
import SwiftyJSON

typealias ScoreStat = (scored:Int, missed:Int)

class StrongMatch : MatchImpl, Actionable {
    
    // Auto Scoring Info
    
    var autoHigh:ScoreStat      = (0, 0)
    var autoLow:ScoreStat       = (0, 0)
    var autoBatters:ScoreStat   = (0, 0)
    var autoCourtyard:ScoreStat = (0, 0)
    var autoDefenses:ScoreStat  = (0, 0)
    
    // Scoring Info
    
    var teleHigh:ScoreStat      = (0, 0)
    var teleLow:ScoreStat       = (0, 0)
    var teleBatters:ScoreStat   = (0, 0)
    var teleCourtyard:ScoreStat = (0, 0)
    var teleDefenses:ScoreStat  = (0, 0)
    
    // Defense Info
    
    var defense1 = Defense(withDefenseType: .lowbar)
    var defense2 = Defense()
    var defense3 = Defense()
    var defense4 = Defense()
    var defense5 = Defense()
    lazy var defenses:[Defense] = [self.defense1, self.defense2, self.defense3, self.defense4, self.defense5]
    
    // Action Info
    
    var actionsPerformed:[Action] = []
    
    // Final Info
    
    var finalConfiguration:FinalConfigType = .none
    
    func aggregateActionsPerformed() {
        self.teleHigh      = (0, 0)
        self.teleLow       = (0, 0)
        self.teleBatters   = (0, 0)
        self.teleCourtyard = (0, 0)
        self.teleDefenses  = (0, 0)
        
        self.autoHigh      = (0, 0)
        self.autoLow       = (0, 0)
        self.autoBatters   = (0, 0)
        self.autoCourtyard = (0, 0)
        self.autoDefenses  = (0, 0)
        
        self.defense1.clearStats()
        self.defense2.clearStats()
        self.defense3.clearStats()
        self.defense4.clearStats()
        self.defense5.clearStats()
        
        self.defense1.location = 1
        self.defense2.location = 2
        self.defense3.location = 3
        self.defense4.location = 4
        self.defense5.location = 5
        
        self.finalFouls = 0
        self.finalTechFouls = 0
        self.finalYellowCards = 0
        self.finalRedCards = 0
        
        for action in self.actionsPerformed {
            let a = action
            switch a.data {
            case let .scoreData(score):
                if a.section == .tele {
                    self.teleHigh.scored       += (score.type == .high)          ? 1 : 0
                    self.teleHigh.missed       += (score.type == .missedHigh)    ? 1 : 0
                    self.teleLow.scored        += (score.type == .low)           ? 1 : 0
                    self.teleLow.missed        += (score.type == .missedLow)     ? 1 : 0
                    self.teleBatters.scored   += (score.location == .batter && !score.type.missed)    ? 1 : 0
                    self.teleBatters.missed   += (score.location == .batter && score.type.missed)     ? 1 : 0
                    self.teleCourtyard.scored += (score.location == .courtyard && !score.type.missed) ? 1 : 0
                    self.teleCourtyard.missed += (score.location == .courtyard && score.type.missed)  ? 1 : 0
                    self.teleDefenses.scored  += (score.location == .defenses && !score.type.missed)  ? 1 : 0
                    self.teleDefenses.missed  += (score.location == .defenses && score.type.missed)   ? 1 : 0
                } else {
                    self.autoHigh.scored      += (score.type == .high)          ? 1 : 0
                    self.autoHigh.missed      += (score.type == .missedHigh)    ? 1 : 0
                    self.autoLow.scored       += (score.type == .low)           ? 1 : 0
                    self.autoLow.missed       += (score.type == .missedLow)     ? 1 : 0
                    self.autoBatters.scored   += (score.location == .batter && !score.type.missed)    ? 1 : 0
                    self.autoBatters.missed   += (score.location == .batter && score.type.missed)     ? 1 : 0
                    self.autoCourtyard.scored += (score.location == .courtyard && !score.type.missed) ? 1 : 0
                    self.autoCourtyard.missed += (score.location == .courtyard && score.type.missed)  ? 1 : 0
                    self.autoDefenses.scored  += (score.location == .defenses && !score.type.missed)  ? 1 : 0
                    self.autoDefenses.missed  += (score.location == .defenses && score.type.missed)   ? 1 : 0
                }
                continue
            case let .defenseData(defense):
                if defense.type == self.defense1.type {
                    if a.section == .tele {
                        self.defense1.timesCrossed         += (defense.actionPerformed == .crossed)         ? 1 : 0
                        self.defense1.failedTimesCrossed   += (defense.actionPerformed == .attemptedCross)  ? 1 : 0
                        self.defense1.timesCrossedWithBall += (defense.actionPerformed == .crossedWithBall) ? 1 : 0
                        self.defense1.timesAssistedCross   += (defense.actionPerformed == .assistedCross)   ? 1 : 0
                    } else {
                        self.defense1.autoTimesCrossed         += (defense.actionPerformed == .crossed)         ? 1 : 0
                        self.defense1.autoFailedTimesCrossed   += (defense.actionPerformed == .attemptedCross)  ? 1 : 0
                        self.defense1.autoTimesCrossedWithBall += (defense.actionPerformed == .crossedWithBall) ? 1 : 0
                        self.defense1.autoTimesAssistedCross   += (defense.actionPerformed == .assistedCross)   ? 1 : 0
                    }
                } else if defense.type == self.defense2.type {
                    if a.section == .tele {
                        self.defense2.timesCrossed         += (defense.actionPerformed == .crossed)         ? 1 : 0
                        self.defense2.failedTimesCrossed   += (defense.actionPerformed == .attemptedCross)  ? 1 : 0
                        self.defense2.timesCrossedWithBall += (defense.actionPerformed == .crossedWithBall) ? 1 : 0
                        self.defense2.timesAssistedCross   += (defense.actionPerformed == .assistedCross)   ? 1 : 0
                    } else {
                        self.defense2.autoTimesCrossed         += (defense.actionPerformed == .crossed)         ? 1 : 0
                        self.defense2.autoFailedTimesCrossed   += (defense.actionPerformed == .attemptedCross)  ? 1 : 0
                        self.defense2.autoTimesCrossedWithBall += (defense.actionPerformed == .crossedWithBall) ? 1 : 0
                        self.defense2.autoTimesAssistedCross   += (defense.actionPerformed == .assistedCross)   ? 1 : 0
                    }
                } else if defense.type == self.defense3.type {
                    if a.section == .tele {
                        self.defense3.timesCrossed         += (defense.actionPerformed == .crossed)         ? 1 : 0
                        self.defense3.failedTimesCrossed   += (defense.actionPerformed == .attemptedCross)  ? 1 : 0
                        self.defense3.timesCrossedWithBall += (defense.actionPerformed == .crossedWithBall) ? 1 : 0
                        self.defense3.timesAssistedCross   += (defense.actionPerformed == .assistedCross)   ? 1 : 0
                    } else {
                        self.defense3.autoTimesCrossed         += (defense.actionPerformed == .crossed)         ? 1 : 0
                        self.defense3.autoFailedTimesCrossed   += (defense.actionPerformed == .attemptedCross)  ? 1 : 0
                        self.defense3.autoTimesCrossedWithBall += (defense.actionPerformed == .crossedWithBall) ? 1 : 0
                        self.defense3.autoTimesAssistedCross   += (defense.actionPerformed == .assistedCross)   ? 1 : 0
                    }
                } else if defense.type == self.defense4.type {
                    if a.section == .tele {
                        self.defense4.timesCrossed         += (defense.actionPerformed == .crossed)         ? 1 : 0
                        self.defense4.failedTimesCrossed   += (defense.actionPerformed == .attemptedCross)  ? 1 : 0
                        self.defense4.timesCrossedWithBall += (defense.actionPerformed == .crossedWithBall) ? 1 : 0
                        self.defense4.timesAssistedCross   += (defense.actionPerformed == .assistedCross)   ? 1 : 0
                    } else {
                        self.defense4.autoTimesCrossed         += (defense.actionPerformed == .crossed)         ? 1 : 0
                        self.defense4.autoFailedTimesCrossed   += (defense.actionPerformed == .attemptedCross)  ? 1 : 0
                        self.defense4.autoTimesCrossedWithBall += (defense.actionPerformed == .crossedWithBall) ? 1 : 0
                        self.defense4.autoTimesAssistedCross   += (defense.actionPerformed == .assistedCross)   ? 1 : 0
                    }
                } else if defense.type == self.defense5.type {
                    if a.section == .tele {
                        self.defense5.timesCrossed         += (defense.actionPerformed == .crossed)         ? 1 : 0
                        self.defense5.failedTimesCrossed   += (defense.actionPerformed == .attemptedCross)  ? 1 : 0
                        self.defense5.timesCrossedWithBall += (defense.actionPerformed == .crossedWithBall) ? 1 : 0
                        self.defense5.timesAssistedCross   += (defense.actionPerformed == .assistedCross)   ? 1 : 0
                    } else {
                        self.defense5.autoTimesCrossed         += (defense.actionPerformed == .crossed)         ? 1 : 0
                        self.defense5.autoFailedTimesCrossed   += (defense.actionPerformed == .attemptedCross)  ? 1 : 0
                        self.defense5.autoTimesCrossedWithBall += (defense.actionPerformed == .crossedWithBall) ? 1 : 0
                        self.defense5.autoTimesAssistedCross   += (defense.actionPerformed == .assistedCross)   ? 1 : 0
                    }
                }
                continue
            case let .penaltyData(penalty):
                self.finalFouls       += (penalty == .foul)       ? 1 : 0
                self.finalTechFouls   += (penalty == .techFoul)   ? 1 : 0
                self.finalYellowCards += (penalty == .yellowCard) ? 1 : 0
                self.finalRedCards    += (penalty == .redCard)    ? 1 : 0
                continue
            default:
                continue
            }
        }
        self.defenses = [defense1, defense2, defense3, defense4, defense5]
    }
    
    required init(queueData:MatchQueueData) {
        super.init(queueData:queueData)
    }
    
    required init() {
        // Init
        super.init()
    }
    
    required init(withPList pList: [String : AnyObject]) {
        
        // Call super to init team and info
        super.init(withPList: pList)
        
        let auto = pList["auto"] as! [String:AnyObject]
        let tele = pList["tele"] as! [String:AnyObject]
        let defense = pList["defense"] as! [String:AnyObject]
        
        // Auto Info
        autoHigh.scored      = auto["scoreHigh"]       as! Int
        autoHigh.missed      = auto["missedHigh"]      as! Int
        autoLow.scored       = auto["scoreLow"]        as! Int
        autoLow.missed       = auto["missedLow"]       as! Int
        autoBatters.scored   = auto["scoreBatters"]    as! Int
        autoBatters.missed   = auto["missedBatters"]   as! Int
        autoCourtyard.scored = auto["scoreCourtyard"]  as! Int
        autoCourtyard.missed = auto["missedCourtyard"] as! Int
        autoDefenses.scored  = auto["scoreDefenses"]   as! Int
        autoDefenses.missed  = auto["missedDefenses"]  as! Int
        
        // Tele Info
        teleHigh.scored      = tele["scoreHigh"]       as! Int
        teleHigh.missed      = tele["missedHigh"]      as! Int
        teleLow.scored       = tele["scoreLow"]        as! Int
        teleLow.missed       = tele["missedLow"]       as! Int
        teleBatters.scored   = tele["scoreBatters"]    as! Int
        teleBatters.missed   = tele["missedBatters"]   as! Int
        teleCourtyard.scored = tele["scoreCourtyard"]  as! Int
        teleCourtyard.missed = tele["missedCourtyard"] as! Int
        teleDefenses.scored  = tele["scoreDefenses"]   as! Int
        teleDefenses.missed  = tele["missedDefenses"]  as! Int
        
        // Defense Info
        let def1data = defense["defense1"] as! NSDictionary
        defense1 = Defense(propertyListRepresentation: def1data)!
        
        let def2data = defense["defense2"] as! NSDictionary
        defense2 = Defense(propertyListRepresentation: def2data)!
        
        let def3data = defense["defense3"] as! NSDictionary
        defense3 = Defense(propertyListRepresentation: def3data)!
        
        let def4data = defense["defense4"] as! NSDictionary
        defense4 = Defense(propertyListRepresentation: def4data)!
        
        let def5data = defense["defense5"] as! NSDictionary
        defense5 = Defense(propertyListRepresentation: def5data)!
    }

    override var messageDictionary:Dictionary<String, AnyObject> {
        var data:[String:AnyObject]    = [String:AnyObject]()
        var team:[String:AnyObject]    = [String:AnyObject]()
        var auto:[String:AnyObject]    = [String:AnyObject]()
        var tele:[String:AnyObject]    = [String:AnyObject]()
        var defense:[String:AnyObject] = [String:AnyObject]()
        var final:[String:AnyObject]   = [String:AnyObject]()
        
        // Team Info
        team["teamNumber"]  = teamNumber as AnyObject?
        team["matchNumber"] = matchNumber as AnyObject?
        team["alliance"]    = alliance.toString() as AnyObject?
        
        // Auto
        auto["scoreHigh"]       = autoHigh.scored as AnyObject?
        auto["missedHigh"]      = autoHigh.missed as AnyObject?
        auto["scoreLow"]        = autoLow.scored as AnyObject?
        auto["missedLow"]       = autoLow.missed as AnyObject?
        auto["scoreBatters"]    = autoBatters.scored as AnyObject?
        auto["missedBatters"]   = autoBatters.missed as AnyObject?
        auto["scoreCourtyard"]  = autoCourtyard.scored as AnyObject?
        auto["missedCourtyard"] = autoCourtyard.missed as AnyObject?
        auto["scoreDefenses"]   = autoDefenses.scored as AnyObject?
        auto["missedDefenses"]  = autoDefenses.missed as AnyObject?
        
        // Score
        tele["scoreHigh"]       = teleHigh.scored as AnyObject?
        tele["missedHigh"]      = teleHigh.missed as AnyObject?
        tele["scoreLow"]        = teleLow.scored as AnyObject?
        tele["missedLow"]       = teleLow.missed as AnyObject?
        tele["scoreBatters"]    = teleBatters.scored as AnyObject?
        tele["missedBatters"]   = teleBatters.missed as AnyObject?
        tele["scoreCourtyard"]  = teleCourtyard.scored as AnyObject?
        tele["missedCourtyard"] = teleCourtyard.missed as AnyObject?
        tele["scoreDefenses"]   = teleDefenses.scored as AnyObject?
        tele["missedDefenses"]  = teleDefenses.missed as AnyObject?

        
        // Defenses
        defense["defense1"] = defense1.propertyListRepresentation()
        defense["defense2"] = defense2.propertyListRepresentation()
        defense["defense3"] = defense3.propertyListRepresentation()
        defense["defense4"] = defense4.propertyListRepresentation()
        defense["defense5"] = defense5.propertyListRepresentation()
        
        // Final Info
        final["score"]    = finalScore as AnyObject?
        final["rPoints"]  = finalRankingPoints as AnyObject?
        final["result"]   = finalResult.rawValue as AnyObject?
        final["pScore"]   = finalPenaltyScore as AnyObject?
        final["fouls"]    = finalFouls as AnyObject?
        final["tFouls"]   = finalTechFouls as AnyObject?
        final["yCards"]   = finalYellowCards as AnyObject?
        final["rCards"]   = finalRedCards as AnyObject?
        final["robot"]    = finalRobot.rawValue as AnyObject?
        final["config"]   = finalConfiguration.rawValue as AnyObject?
        final["comments"] = finalComments as AnyObject?
        
        // All Data
        data["team"]    = team as AnyObject?
        data["auto"]    = auto as AnyObject?
        data["tele"]    = tele as AnyObject?
        data["defense"] = defense as AnyObject?
        data["final"]   = final as AnyObject?
        
        return data
    }
    
    override var encodingHelper: MatchEncodingHelper {
        return StrongMatchEncodingHelper(match:self)
    }
    
    override class var csvHeader:String {
        var matchHeader = ""
        
        matchHeader += "Match Number, Team Number, Alliance, "
        
        matchHeader += "Auto Scored High, Auto Missed High, Auto Scored Low, Auto Missed Low, "
        matchHeader += "Auto Scored Batters, Auto Missed Batters, Auto Scored Courtyard, Auto Missed Courtyard, Auto Scored Defenses, Auto Missed Defenses, "
        
        matchHeader += "Tele Scored High, Tele Missed High, Tele Scored Low, Tele Missed Low, "
        matchHeader += "Tele Scored Batters, Tele Missed Batters, Tele Scored Courtyard, Tele Missed Courtyard, Tele Scored Defenses, Tele Missed Defenses, "
        
        matchHeader += "Defense 1 Type, "
        matchHeader += "D1 Auto Crossed, D1 Auto Attempted Cross, D1 Auto Crossed With Ball, D1 Auto Assisted Cross, "
        matchHeader += "D1 Tele Crossed, D1 Tele Attempted Cross, D1 Tele Crossed With Ball, D1 Tele Assisted Cross, "
        
        matchHeader += "Defense 2 Type, "
        matchHeader += "D2 Auto Crossed, D2 Auto Attempted Cross, D2 Auto Crossed With Ball, D2 Auto Assisted Cross, "
        matchHeader += "D2 Tele Crossed, D2 Tele Attempted Cross, D2 Tele Crossed With Ball, D2 Tele Assisted Cross, "
        
        matchHeader += "Defense 3 Type, "
        matchHeader += "D3 Auto Crossed, D3 Auto Attempted Cross, D3 Auto Crossed With Ball, D3 Auto Assisted Cross, "
        matchHeader += "D3 Tele Crossed, D3 Tele Attempted Cross, D3 Tele Crossed With Ball, D3 Tele Assisted Cross, "
        
        matchHeader += "Defense 4 Type, "
        matchHeader += "D4 Auto Crossed, D4 Auto Attempted Cross, D4 Auto Crossed With Ball, D4 Auto Assisted Cross, "
        matchHeader += "D4 Tele Crossed, D4 Tele Attempted Cross, D4 Tele Crossed With Ball, D4 Tele Assisted Cross, "
        
        matchHeader += "Defense 5 Type, "
        matchHeader += "D5 Auto Crossed, D5 Auto Attempted Cross, D5 Auto Crossed With Ball, D5 Auto Assisted Cross, "
        matchHeader += "D5 Tele Crossed, D5 Tele Attempted Cross, D5 Tele Crossed With Ball, D5 Tele Assisted Cross, "
        
        matchHeader += "Final Score, Final Ranking Points, Penalty Points Received, Final Result, Fouls, Tech Fouls, Yellow Cards, Red Cards, Robot, Config, Comments \r\n"
        
        return matchHeader
    }
    
    override var csvMatch:String {
        var matchData = ""
        let match = JSON(messageDictionary)
        
        matchData += "\(match["team", "matchNumber"].intValue),"
        matchData += "\(match["team", "teamNumber"].intValue),"
        matchData += "\(match["team", "alliance"].stringValue),"
        
        let typeKeys = ["auto", "tele"]
        let scoreKeys = ["scoreHigh", "missedHigh", "scoreLow", "missedLow", "scoreBatters", "missedBatters", "scoreCourtyard", "missedCourtyard", "scoreDefenses", "missedDefenses"]
        for i in 0..<typeKeys.count {
            for j in 0..<scoreKeys.count {
                matchData += "\(match[typeKeys[i], scoreKeys[j]].intValue),"
            }
        }
        
        let defenseNames = ["defense1", "defense2", "defense3", "defense4", "defense5"]
        let defenseVals = ["type", "atcross", "afcross", "abcross", "aacross", "cross", "fcross", "bcross", "across"]
        for i in 0..<defenseNames.count {
            for j in 0..<defenseVals.count {
                matchData += "\(match["defense", defenseNames[i], defenseVals[j]].intValue),"
            }
        }
        
        let finalKeys = ["score", "rPoints", "pScore", "result", "fouls", "tFouls", "yCards", "rCards", "robot", "config"]
        for i in 0..<finalKeys.count {
            matchData += "\(match["final", finalKeys[i]].intValue),"
        }
        matchData += "\(match["final", "comments"].stringValue)"

        return matchData
    }
    
    override func updateForType(_ type:UpdateType, withMatch match:Match) {
        let m = match as! StrongMatch
        switch type {
        case .teamInfo:
            teamNumber  = m.teamNumber
            matchNumber = m.matchNumber
            alliance    = m.alliance
            isCompleted = m.isCompleted
            finalResult = m.finalResult
            break;
        case .fieldSetup:
            defense1.type = m.defense1.type
            defense2.type = m.defense2.type
            defense3.type = m.defense3.type
            defense4.type = m.defense4.type
            defense5.type = m.defense5.type
            defenses = [(defense1), (defense2), (defense3), (defense4), (defense5)]
            break;
        case .finalStats:
            finalScore         = m.finalScore
            finalRankingPoints = m.finalRankingPoints
            finalResult        = m.finalResult
            finalPenaltyScore  = m.finalPenaltyScore
            finalConfiguration = m.finalConfiguration
            finalComments      = m.finalComments
        case .actionsEdited:
            actionsPerformed = m.actionsPerformed
        default:
            break;
        }
    }
    
    func updateMatchWithAction(_ action:Action) {
        print("Adding Action: \(action.type)")
        switch action.data {
        case let .scoreData(score):
            print("\tScoreType: \(score.type.toString())")
            print("\tScoreLoc:  \(score.location.toString())")
            break
        case let .defenseData(defense):
            print("\tDefenseType:   \(defense.type.toString())")
            print("\tDefenseAction: \(defense.actionPerformed.toString())")
            if(1...3 ~= defense.actionPerformed.rawValue && action.section == .auto) {
                isCompleted |= 8;
            }
            break
        case let .penaltyData(penalty):
            print("\tPenaltyType: \(penalty.toString())")
            break
        default:
            break
        }
        actionsPerformed.append(action)
    }
    
    override func aggregateMatchData() {
        aggregateActionsPerformed()
    }
}

class StrongMatchEncodingHelper : MatchEncodingHelper {
    
    override init(match:Match) {
        super.init(match: match)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        // use decoder to get dictionary
        guard let pList = aDecoder.decodeObject(forKey: "pListData") as? [String:AnyObject] else {
            super.init()
            match = nil
            return
        }
        
        super.init()
        
        // convert dictionary to match here
        match = StrongMatch(withPList: pList)
    }
    
    override func propertyListRepresentation() throws -> [String:AnyObject] {
        var auto    = [String:AnyObject]()
        var tele    = [String:AnyObject]()
        var defense = [String:AnyObject]()
        
        // call super to get the tele and final information
        guard var data = try? super.propertyListRepresentation() else {
            throw MatchEncodingError.NoMatchData
        }
        
        guard let m = match as? StrongMatch else {
            throw MatchEncodingError.NoMatchData
        }
        
        // Auto Info
        auto["scoreHigh"]       = m.autoHigh.scored      as AnyObject?
        auto["missedHigh"]      = m.autoHigh.missed      as AnyObject?
        auto["scoreLow"]        = m.autoLow.scored       as AnyObject?
        auto["missedLow"]       = m.autoLow.missed       as AnyObject?
        auto["scoreBatters"]    = m.autoBatters.scored   as AnyObject?
        auto["missedBatters"]   = m.autoBatters.missed   as AnyObject?
        auto["scoreCourtyard"]  = m.autoCourtyard.scored as AnyObject?
        auto["missedCourtyard"] = m.autoCourtyard.missed as AnyObject?
        auto["scoreDefenses"]   = m.autoDefenses.scored  as AnyObject?
        auto["missedDefenses"]  = m.autoDefenses.missed  as AnyObject?
        
        // Tele Info
        tele["scoreHigh"]       = m.teleHigh.scored      as AnyObject?
        tele["missedHigh"]      = m.teleHigh.missed      as AnyObject?
        tele["scoreLow"]        = m.teleLow.scored       as AnyObject?
        tele["missedLow"]       = m.teleLow.missed       as AnyObject?
        tele["scoreBatters"]    = m.teleBatters.scored   as AnyObject?
        tele["missedBatters"]   = m.teleBatters.missed   as AnyObject?
        tele["scoreCourtyard"]  = m.teleCourtyard.scored as AnyObject?
        tele["missedCourtyard"] = m.teleCourtyard.missed as AnyObject?
        tele["scoreDefenses"]   = m.teleDefenses.scored  as AnyObject?
        tele["missedDefenses"]  = m.teleDefenses.missed  as AnyObject?
        
        // Defense Info
        defense["defense1"]     = m.defense1.propertyListRepresentation()
        defense["defense2"]     = m.defense2.propertyListRepresentation()
        defense["defense3"]     = m.defense3.propertyListRepresentation()
        defense["defense4"]     = m.defense4.propertyListRepresentation()
        defense["defense5"]     = m.defense5.propertyListRepresentation()
        
        
        data["auto"]            = auto                   as AnyObject?
        data["tele"]            = tele                   as AnyObject?
        data["defense"]         = defense                as AnyObject?
        return data;
    }
}

