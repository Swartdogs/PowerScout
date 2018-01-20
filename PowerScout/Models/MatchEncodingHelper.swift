//
//  MatchEncodingHelper.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/12/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation

enum MatchEncodingError : Error {
    case WrongFormat
    case NoMatchData
}

class MatchEncodingHelper : NSObject, NSCoding {
    var match:Match?
    
    override init() {
        super.init()
    }
    
    init(match:Match) {
        self.match = match
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        // use decoder to get dictionary
        guard let pList = aDecoder.decodeObject(forKey: "pListData") as? [String:AnyObject] else {
            match = nil
            super.init()
            return
        }
        
        // convert dictionary to match here
        match = MatchImpl(withPList: pList)
        
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        guard let pList = try? propertyListRepresentation() else {
            return
        }
        
        aCoder.encode(pList, forKey:"pListData")
    }
    
    func propertyListRepresentation() throws -> [String:AnyObject] {
        var data = [String:AnyObject]()
        var team = [String:AnyObject]()
        var final = [String:AnyObject]()
        
        guard let m = match else {
            throw MatchEncodingError.NoMatchData
        }
        
        // Team Info
        team["teamNumber"]  = m.teamNumber           as AnyObject?
        team["matchNumber"] = m.matchNumber          as AnyObject?
        team["alliance"]    = m.alliance.rawValue    as AnyObject?
        team["isCompleted"] = m.isCompleted          as AnyObject?
        
        // Final Info
        final["score"]      = m.finalScore           as AnyObject?
        final["rPoints"]    = m.finalRankingPoints   as AnyObject?
        final["result"]     = m.finalResult.rawValue as AnyObject?
        final["pScore"]     = m.finalPenaltyScore    as AnyObject?
        final["fouls"]      = m.finalFouls           as AnyObject?
        final["tFouls"]     = m.finalTechFouls       as AnyObject?
        final["yCards"]     = m.finalYellowCards     as AnyObject?
        final["rCards"]     = m.finalRedCards        as AnyObject?
        final["robot"]      = m.finalRobot.rawValue  as AnyObject?
        final["comments"]   = m.finalComments        as AnyObject?
        
        data["team"]        = team                   as AnyObject?
        data["final"]       = final                  as AnyObject?
        
        return data;
    }
}
