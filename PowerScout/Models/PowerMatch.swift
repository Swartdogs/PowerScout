//
//  PowerMatch.swift
//  PowerScout
//
//  Created by Srinivas Dhanwada on 2/5/18.
//  Copyright © 2018 FRC Team 525. All rights reserved.
//

import Foundation
import SwiftyJSON

class PowerMatch : MatchImpl {
    // Auto Info
    var autoStartPos:PowerStartPositionType = .none
    var autoCrossedLine:Bool = false
    var autoScaleBlocks:Int = 0
    var autoSwitchBlocks:Int = 0
    
    // Teleop Info
    var teleScaleBlocks:Int = 0
    var teleSwitchBlocks:Int = 0
    var teleExchangeBlocks:Int = 0
    var teleLow:Bool = false
    var teleNormal:Bool =  false
    var teleHigh:Bool = false
    
    // End Game Info
    var endClimb:Bool = false
    var endClimbCondition:PowerEndClimbPositionType = .none
    
    required init() {
        super.init()
    }
    
    required init(queueData: MatchQueueData) {
        super.init(queueData: queueData)
    }
    
    required init(withPList pList: [String : AnyObject]) {
        super.init(withPList: pList)
        
        let json = JSON(pList)
        
        // Auto Info
        autoStartPos = PowerStartPositionType(rawValue: json["auto"]["startPos"].intValue)!
        autoCrossedLine = json["auto"]["crossed"].boolValue
        autoScaleBlocks = json["auto"]["scale"].intValue
        autoSwitchBlocks = json["auto"]["switch"].intValue
        
        // Tele Info
        teleScaleBlocks = json["tele"]["scale"].intValue
        teleSwitchBlocks = json["tele"]["switch"].intValue
        teleExchangeBlocks = json["tele"]["exchange"].intValue
        teleLow = json["tele"]["low"].boolValue
        teleNormal = json["tele"]["normal"].boolValue
        teleHigh = json["tele"]["high"].boolValue
        
        // End Game Info
        endClimb = json["endg"]["climb"].boolValue
        endClimbCondition = PowerEndClimbPositionType(rawValue: json["endg"]["climbCond"].intValue)!
    }
    
    override var messageDictionary: [String : AnyObject] {
        var data = super.messageDictionary
        var auto = [String:AnyObject]()
        var tele = [String:AnyObject]()
        var endg = [String:AnyObject]()
        
        // Auto Info
        auto["startPos"] = autoStartPos.rawValue as AnyObject?
        auto["crossed"] = autoCrossedLine as AnyObject?
        auto["scale"] = autoScaleBlocks as AnyObject?
        auto["switch"] = autoSwitchBlocks as AnyObject?
        
        // Tele Info
        tele["scale"] = teleScaleBlocks as AnyObject?
        tele["switch"] = teleSwitchBlocks as AnyObject?
        tele["exchange"] = teleExchangeBlocks as AnyObject?
        tele["low"] = teleLow as AnyObject?
        tele["normal"] = teleNormal as AnyObject?
        tele["high"] = teleHigh as AnyObject?
        
        // End Game Info
        endg["climb"] = endClimb as AnyObject?
        endg["climbCond"] = endClimbCondition.rawValue as AnyObject?
        
        data["auto"] = auto as AnyObject?
        data["tele"] = tele as AnyObject?
        data["endg"] = endg as AnyObject?
        
        return data
    }
    
    override class var csvHeader: String {
        var matchHeader = ""
        // Team Info
        matchHeader += "Match Number, Team Number, Alliance, "
        
        // Auto Info
        matchHeader += "Auto Start Position, Auto Line Crossed, Auto Scale Blocks, Auto Switch Blocks, "
        
        // Tele Info
        matchHeader += "Tele Scale Blocks, Tele Switch Blocks, Tele Exchange Blocks, Tele Low, Tele Normal, Tele High, "
        
        // End Game Info
        matchHeader += "End Game Climb, End Game Climb Condition, "
        
        // Final Info
        matchHeader += "Final Score, Final Ranking Points, Penalty Points Received, Final Result, Fouls, Tech Fouls, Yellow Cards, Red Cards, Robot, Config, Comments \r\n"
        
        return matchHeader
    }
    
    override var csvMatch: String {
        var matchData = ""
        let match = JSON(messageDictionary)
        
        // Team Info
        matchData += "\(match["team", "matchNumber"].intValue), "
        matchData += "\(match["team", "teamNumber"].intValue), "
        matchData += "\(match["team", "alliance"].intValue), "
        
        // Auto Info
        matchData += "\(match["auto", "startPos"].intValue), "
        matchData += "\(match["auto", "crossed"].boolValue), "
        matchData += "\(match["auto", "scale"].intValue), "
        matchData += "\(match["auto", "switch"].intValue), "
        
        // Tele Info
        matchData += "\(match["tele", "scale"].intValue), "
        matchData += "\(match["tele", "switch"].intValue), "
        matchData += "\(match["tele", "exchange"].intValue), "
        matchData += "\(match["tele", "low"].boolValue), "
        matchData += "\(match["tele", "normal"].boolValue), "
        matchData += "\(match["tele", "high"].boolValue), "
        
        // End Game Info
        matchData += "\(match["endg", "climb"].boolValue), "
        matchData += "\(match["endg", "climbCond"].intValue), "
        
        // Final Info
        matchData += "\(match["final", "score"].intValue),"
        matchData += "\(match["final", "rPoints"].intValue),"
        matchData += "\(match["final", "pScore"].intValue),"
        matchData += "\(match["final", "result"].intValue),"
        matchData += "\(match["final", "fouls"].intValue),"
        matchData += "\(match["final", "tFouls"].intValue),"
        matchData += "\(match["final", "yCards"].intValue),"
        matchData += "\(match["final", "rCards"].intValue),"
        matchData += "\(match["final", "robot"].intValue),"
        matchData += "\(match["final", "config"].intValue),"
        matchData += "\(match["final", "comments"].stringValue)"
        
        return matchData
    }
    
    override func updateForType(_ type: UpdateType, withMatch match: Match) {
        // Do Nothing
    }
    
    override func aggregateMatchData() {
        // Do Nothing
    }
}
