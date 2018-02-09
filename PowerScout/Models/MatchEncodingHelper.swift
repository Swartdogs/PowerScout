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
        
        // Capture Match Type
        guard let matchTypeName = pList["matchType"] as? String else {
            match = nil
            super.init()
            return
        }
        
        guard let matchType = NSClassFromString(matchTypeName) as? Match.Type else {
            match = nil
            super.init()
            return
        }
        
        // convert dictionary to match here
        match = matchType.init(withPList: pList)
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        guard let plistData = try? propertyListRepresentation() else {
            return // Return early
        }
        
        aCoder.encode(plistData, forKey:"pListData")
    }
    
    func propertyListRepresentation() throws -> [String:AnyObject] {
        guard let m = match else {
            throw MatchEncodingError.NoMatchData
        }
        
        return m.messageDictionary
    }
}
