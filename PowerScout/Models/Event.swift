//
//  Event.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/17/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit
import SwiftyJSON

class Event: NSObject, NSCoding {
    
    var city:String         = ""
    var code:String         = ""
    var country:String      = ""
    var dateStart:Date?   = nil
    var dateEnd:Date?     = nil
    var districtCode:String = ""
    var divisionCode:String = ""
    var name:String         = ""
    var stateProv:String    = ""
    var timezone:String     = ""
    var type:String         = ""
    var venue:String        = ""

    init(json:JSON) {
        super.init()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let abbr = timeZoneToABBR(json["timezone"].stringValue)
        if abbr == "AEST" { // Fix for Australia Time
            formatter.timeZone = TimeZone(identifier: "Australia/Sydney")
        } else {
            formatter.timeZone = TimeZone(abbreviation: abbr)
        }
        
        self.city         = json["city"].stringValue
        self.code         = json["code"].stringValue
        self.country      = json["country"].stringValue
        self.dateStart    = formatter.date(from: json["dateStart"].stringValue)
        self.dateEnd      = formatter.date(from: json["dateEnd"].stringValue)
        self.districtCode = json["districtCode"].stringValue
        self.divisionCode = json["divisionCode"].stringValue
        self.name         = json["name"].stringValue
        self.stateProv    = json["stateprov"].stringValue
        self.timezone     = json["timezone"].stringValue
        self.type         = json["type"].stringValue
        self.venue        = json["venue"].stringValue
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.city         = aDecoder.decodeObject(forKey: "city")         as! String
        self.code         = aDecoder.decodeObject(forKey: "code")         as! String
        self.country      = aDecoder.decodeObject(forKey: "country")      as! String
        self.dateStart    = aDecoder.decodeObject(forKey: "dateStart")    as? Date
        self.dateEnd      = aDecoder.decodeObject(forKey: "dateEnd")      as? Date
        self.districtCode = aDecoder.decodeObject(forKey: "districtCode") as! String
        self.divisionCode = aDecoder.decodeObject(forKey: "divisionCode") as! String
        self.name         = aDecoder.decodeObject(forKey: "name")         as! String
        self.stateProv    = aDecoder.decodeObject(forKey: "stateProv")    as! String
        self.timezone     = aDecoder.decodeObject(forKey: "timeZone")     as! String
        self.type         = aDecoder.decodeObject(forKey: "type")         as! String
        self.venue        = aDecoder.decodeObject(forKey: "venue")        as! String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(city,           forKey: "city")
        aCoder.encode(code,           forKey: "code")
        aCoder.encode(country,        forKey: "country")
        aCoder.encode(dateStart,      forKey: "dateStart")
        aCoder.encode(dateEnd,        forKey: "dateEnd")
        aCoder.encode(districtCode,   forKey: "districtCode")
        aCoder.encode(divisionCode,   forKey: "divisionCode")
        aCoder.encode(name,           forKey: "name")
        aCoder.encode(stateProv,      forKey: "stateProv")
        aCoder.encode(timezone,       forKey: "timeZone")
        aCoder.encode(type,           forKey: "type")
        aCoder.encode(venue,          forKey: "venue")
    }
    
    func timeZoneToABBR(_ tz:String) -> String {
        /*
        ["Israel Standard Time", "Eastern Standard Time", "Central Standard Time", "E. Australia Standard Time", "Mountain Standard Time", "Pacific Standard Time", "Hawaiian Standard Time"]
        
        ["IST", "EST", "CST", "AEST", "MST", "PST", "HST"]
        // Australia time currently does not work -- SEE FIX ABOVE
        */
        return tz == "Israel Standard Time"       ? "IST"  :
               tz == "Eastern Standard Time"      ? "EST"  :
               tz == "Central Standard Time"      ? "CST"  :
               tz == "E. Australia Standard Time" ? "AEST"  :
               tz == "Mountain Standard Time"     ? "MST"  :
               tz == "Pacific Standard Time"      ? "PST"  :
               tz == "Hawaiian Standard Time"     ? "HST" : "UTC"
    }
    
}
