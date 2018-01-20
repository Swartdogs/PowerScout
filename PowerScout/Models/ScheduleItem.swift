//
//  ScheduleItem.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/18/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit
import SwiftyJSON

struct Team: PropertyListReadable {
    var teamNumber:Int = 0
    var station:String = ""
    var surrogate:Bool = false
    
    init?(propertyListRepresentation: NSDictionary?) {
        guard let vals = propertyListRepresentation else {return nil}
        if let tNum = vals["tNum"] as? Int,
               let station = vals["station"] as? String,
               let surrogate = vals["surr"] as? Bool {
                self.teamNumber = tNum
                self.station = station
                self.surrogate = surrogate
        } else {
            return nil
        }
    }
    
    init(json:JSON) {
        self.teamNumber = json["teamNumber"].intValue
        self.station = json["station"].stringValue
        self.surrogate = json["surrogate"].boolValue
    }
    
    func propertyListRepresentation() -> NSDictionary {
        return ["tNum":teamNumber, "station":station, "surr":surrogate]
    }
}

class ScheduleItem: NSObject, NSCoding {
    var desc:String = ""
    var field:String = ""
    var tournamentLevel:String = ""
    var matchNumber:Int = 0
    var startTime:Date? = nil
    var teams:[Team] = [Team]()
    
    init(json:JSON) {
        super.init()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        self.desc            = json["description"].stringValue
        self.field           = json["field"].stringValue
        self.tournamentLevel = json["tournamentLevel"].stringValue
        self.matchNumber     = json["matchNumber"].intValue
        self.startTime       = formatter.date(from: json["startTime"].stringValue)
        self.teams           = [Team]()
        for (_,subJSON):(String,JSON) in json["Teams"] {
            let team = Team(json: subJSON)
            teams.append(team)
        }
        
        teams.sort(by: {$0.station.compare($1.station) == .orderedAscending})
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        self.desc            = aDecoder.decodeObject(forKey: "desc") as! String
        self.field           = aDecoder.decodeObject(forKey: "field") as! String
        self.tournamentLevel = aDecoder.decodeObject(forKey: "tLevel") as! String
        self.matchNumber     = aDecoder.decodeInteger(forKey: "mNum")
        self.startTime       = aDecoder.decodeObject(forKey: "sTime") as? Date
        
        let teamsPList = aDecoder.decodeObject(forKey: "teams") as? [NSDictionary]
        self.teams = []
        for pList in teamsPList! {
            guard let team = Team(propertyListRepresentation: pList) else { continue }
            self.teams.append(team)
        }
        teams.sort(by: {$0.station.compare($1.station) == .orderedAscending})
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(desc,            forKey: "desc")
        aCoder.encode(field,           forKey: "field")
        aCoder.encode(tournamentLevel, forKey: "tLevel")
        aCoder.encode(matchNumber,    forKey: "mNum")
        aCoder.encode(startTime,       forKey: "sTime")
        
        var teamsPList:[NSDictionary] = []
        for t in teams {
            teamsPList.append(t.propertyListRepresentation())
        }
        aCoder.encode(teamsPList, forKey: "teams")
    }
}
