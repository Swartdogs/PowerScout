//
//  Match.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 2/6/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol Actionable {
    func updateMatchWithAction(_ action:Action)
    func aggregateActionsPerformed()
}

protocol CsvDataProvider {
    static var csvHeader:String { get }
    var csvMatch:String { get }
}

protocol MatchCoding {
    init(withPList pList:[String:AnyObject])
    
    var encodingHelper:MatchEncodingHelper { get }
}

protocol Match : CsvDataProvider, MatchCoding {
    
    // Team Info
    
    var teamNumber:Int         { get set }
    var matchNumber:Int        { get set }
    var alliance:AllianceType  { get set }
    var isCompleted:Int        { get set }
    
    // Data Transfer
    
    var lastExportedByFile:Date? { get set }
    var lastExportedByXfer:Date? { get set }
    var shouldExport:Bool { get set }
    var selectedForDataTransfer:Bool { get set }
    
    // Final Info
    
    var finalScore:Int         { get set }
    var finalRankingPoints:Int { get set }
    var finalResult:ResultType { get set }
    var finalPenaltyScore:Int  { get set }
    var finalFouls:Int         { get set }
    var finalTechFouls:Int     { get set }
    var finalYellowCards:Int   { get set }
    var finalRedCards:Int      { get set }
    var finalRobot:RobotState  { get set }
    var finalComments:String   { get set }
    
    // Calculated Variables
    var messageDictionary:[String:AnyObject] { get }
    
    init(queueData:MatchQueueData)
    
    // Required Functions
    func updateForType(_ type:UpdateType, withMatch match:Match)
    func aggregateMatchData()
}

class MatchImpl : Match {
    
    // Team Info
    
    var teamNumber:Int         = 0
    var matchNumber:Int        = 0
    var alliance:AllianceType  = .unknown
    var isCompleted:Int        = 0
    
    // Data Export
    
    var lastExportedByFile:Date? = nil
    var lastExportedByXfer:Date? = nil
    var shouldExport:Bool = true
    var selectedForDataTransfer: Bool = false
    
    // Final Info
    
    var finalScore:Int         = 0
    var finalRankingPoints:Int = 0
    var finalResult:ResultType = .none
    var finalPenaltyScore:Int  = 0
    var finalFouls:Int         = 0
    var finalTechFouls:Int     = 0
    var finalYellowCards:Int   = 0
    var finalRedCards:Int      = 0
    var finalRobot:RobotState  = .None
    var finalComments:String   = ""
    
    // Calculated Variables
    class var csvHeader:String {
        var matchHeader = ""
        
        matchHeader += "Match Number, Team Number, Alliance, "
        matchHeader += "Final Score, Final Ranking Points, Penalty Points Received, Final Result, Fouls, Tech Fouls, "
        matchHeader += "Yellow Cards, Red Cards, Robot, Config, Comments \r\n"
        
        return matchHeader
    }
    
    var csvMatch:String {
        var matchData = ""
        matchData += "\(matchNumber), \(teamNumber), \(alliance.toString)"
        
        return matchData;
    }
    
    var messageDictionary: [String:AnyObject] {
        var data:[String:AnyObject]    = [String:AnyObject]()
        var team:[String:AnyObject]    = [String:AnyObject]()
        var final:[String:AnyObject]   = [String:AnyObject]()
        var xfer:[String:AnyObject] = [String:AnyObject]()
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        // Team Info
        team["teamNumber"]  = teamNumber           as AnyObject?
        team["matchNumber"] = matchNumber          as AnyObject?
        team["alliance"]    = alliance.rawValue    as AnyObject?
        team["isCompleted"] = isCompleted          as AnyObject?
        
        // Data Transfer
        if let exFile = lastExportedByFile {
            xfer["exportByFile"] = dateFormatter.string(from: exFile) as AnyObject?
        }
        if let exXfer = lastExportedByXfer {
            xfer["exportByXfer"] = dateFormatter.string(from: exXfer) as AnyObject?
        }
        xfer["shouldExport"] = shouldExport as AnyObject?
        xfer["selectedForDT"] = selectedForDataTransfer as AnyObject?
        
        // Final Info
        final["score"]      = finalScore           as AnyObject?
        final["rPoints"]    = finalRankingPoints   as AnyObject?
        final["result"]     = finalResult.rawValue as AnyObject?
        final["pScore"]     = finalPenaltyScore    as AnyObject?
        final["fouls"]      = finalFouls           as AnyObject?
        final["tFouls"]     = finalTechFouls       as AnyObject?
        final["yCards"]     = finalYellowCards     as AnyObject?
        final["rCards"]     = finalRedCards        as AnyObject?
        final["robot"]      = finalRobot.rawValue  as AnyObject?
        final["comments"]   = finalComments        as AnyObject?
        
        // All Data
        data["team"]        = team  as AnyObject?
        data["final"]       = final as AnyObject?
        data["xfer"]        = xfer as AnyObject?
        data["matchType"]   = NSStringFromClass(type(of: self)) as AnyObject?
        
        return data
    }
    
    var encodingHelper: MatchEncodingHelper {
        return MatchEncodingHelper(match: self)
    }
    
    required init() {
        // Init
    }
    
    required init(queueData:MatchQueueData) {
        teamNumber = queueData.teamNumber
        matchNumber = queueData.matchNumber
        alliance = queueData.alliance
    }
    
    required init(withPList pList:[String:AnyObject]) {
        guard let team  = pList["team"]  as? [String:AnyObject],
            let final = pList["final"] as? [String:AnyObject],
            let xfer =  pList["xfer"] as? [String:AnyObject] else {
                return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        // Team Info
        teamNumber         = team["teamNumber"]  as! Int
        matchNumber        = team["matchNumber"] as! Int
        alliance           = AllianceType(rawValue: team["alliance"] as! Int)!
        isCompleted        = team["isCompleted"] as! Int
        
        // Data Transfer
        if let exFile = xfer["exportByFile"] as? String {
            lastExportedByFile = dateFormatter.date(from: exFile)
        } else {
            lastExportedByFile = nil
        }
        if let exXfer = xfer["exportByXfer"] as? String {
            lastExportedByXfer = dateFormatter.date(from: exXfer)
        } else {
            lastExportedByXfer = nil
        }
        shouldExport            = xfer["shouldExport"] as! Bool
        selectedForDataTransfer = xfer["selectedForDT"] as! Bool
        
        // Final Info
        finalScore         = final["score"]      as! Int
        finalRankingPoints = final["rPoints"]    as! Int
        finalResult        = ResultType(rawValue: final["result"] as! Int)!
        finalPenaltyScore  = final["pScore"]     as! Int
        finalFouls         = final["fouls"]      as! Int
        finalTechFouls     = final["tFouls"]     as! Int
        finalYellowCards   = final["yCards"]     as! Int
        finalRedCards      = final["rCards"]     as! Int
        finalRobot         = RobotState(rawValue: final["robot"] as! Int)
        finalComments      = final["comments"]   as! String
    }
    
    // Required Functions
    func updateForType(_ type:UpdateType, withMatch match:Match) {
        fatalError("This method has not been implemented!")
    }
    
    func aggregateMatchData() {
        fatalError("This method has not been implemented!")
    }
    
}

extension MatchImpl: Equatable {
    static func ==(lhs:MatchImpl, rhs:MatchImpl) -> Bool {
        return lhs.matchNumber == rhs.matchNumber && lhs.teamNumber == rhs.teamNumber;
    }
}
