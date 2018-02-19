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
    var autoScaleCubes:Int = 0
    var autoSwitchCubes:Int = 0
    
    // Teleop Info
    var teleScaleCubes:Int = 0
    var teleSwitchCubes:Int = 0
    var teleExchangeCubes:Int = 0
    var teleLow:Bool = false
    var teleNormal:Bool =  false
    var teleHigh:Bool = false
    
    // End Game Info
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
        autoScaleCubes = json["auto"]["scale"].intValue
        autoSwitchCubes = json["auto"]["switch"].intValue
        
        // Tele Info
        teleScaleCubes = json["tele"]["scale"].intValue
        teleSwitchCubes = json["tele"]["switch"].intValue
        teleExchangeCubes = json["tele"]["exchange"].intValue
        teleLow = json["tele"]["low"].boolValue
        teleNormal = json["tele"]["normal"].boolValue
        teleHigh = json["tele"]["high"].boolValue
        
        // End Game Info
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
        auto["scale"] = autoScaleCubes as AnyObject?
        auto["switch"] = autoSwitchCubes as AnyObject?
        
        // Tele Info
        tele["scale"] = teleScaleCubes as AnyObject?
        tele["switch"] = teleSwitchCubes as AnyObject?
        tele["exchange"] = teleExchangeCubes as AnyObject?
        tele["low"] = teleLow as AnyObject?
        tele["normal"] = teleNormal as AnyObject?
        tele["high"] = teleHigh as AnyObject?
        
        // End Game Info
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
        matchHeader += "Auto Start Position, Auto Line Crossed, Auto Scale Cubes, Auto Switch Cubes, "
        
        // Tele Info
        matchHeader += "Tele Scale Cubes, Tele Switch Cubes, Tele Exchange Cubes, Tele Cubes Placed Low, Tele Cubes Placed Balanced, Tele Cubes Placed High, "
        
        // End Game Info
        matchHeader += "End Game Climb Condition, "
        
        // Final Info
        matchHeader += "Received Tech Fouls, End Robot State \r\n"
        
        return matchHeader
    }
    
    override var csvMatch: String {
        var matchData = ""
        let match = JSON(messageDictionary)
        
        // Team Info
        matchData += "\(match["team", "matchNumber"].intValue), "
        matchData += "\(match["team", "teamNumber"].intValue), "
        matchData += "\(AllianceType(rawValue: match["team", "alliance"].intValue)?.toString() ?? "Unknown"), "
        
        // Auto Info
        matchData += "\(PowerStartPositionType(rawValue: match["auto", "startPos"].intValue)?.toString() ?? "Unknown"), "
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
        matchData += "\(PowerEndClimbPositionType(rawValue: match["endg", "climbCond"].intValue)?.toString() ?? "Unknown"), "
        
        // Final Info
        matchData += "\(match["final", "tFouls"].intValue == 1 ? "Yes" : "No"),"
        matchData += "\(RobotState(rawValue: match["final", "robot"].intValue).toString()),"
        
        return matchData
    }
    
    override func updateForType(_ type: UpdateType, withMatch match: Match) {
        // Do Nothing
    }
    
    override func aggregateMatchData() {
        // Do Nothing
    }
}
