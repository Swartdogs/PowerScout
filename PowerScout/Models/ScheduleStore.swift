//
//  ScheduleStore.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/18/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit
import SwiftyJSON

class ScheduleStore: NSObject {
    
    static let sharedStore:ScheduleStore = ScheduleStore()
    
    var requestProgressUpdate:((Double) -> ())? = nil
    var requestCompletion:((NSError?) -> ())? = nil
    var requestCanceled:(() -> ())? = nil
    
    var schedule:[ScheduleItem] = []
    
    var currentSchedule:String? {
        didSet {
            if currentSchedule == nil {
                UserDefaults.standard.set(nil, forKey: "SteamScout.currentSchedule")
            } else {
                UserDefaults.standard.set(currentSchedule, forKey: "SteamScout.currentSchedule")
            }
        }
    }

    fileprivate override init() {
        super.init()
        
        currentSchedule = UserDefaults.standard.object(forKey: "SteamScout.currentSchedule") as? String
        
        let path = self.scheduleArchivePath()
        schedule = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? [ScheduleItem] ?? schedule
    }
    
    func scheduleArchivePath() -> String {
        let documentFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return (documentFolder as NSString).appendingPathComponent("Schedule.archive")
    }
    
    func saveSchedule() -> Bool {
        let path = self.scheduleArchivePath()
        return NSKeyedArchiver.archiveRootObject(schedule, toFile: path)
    }
    
    func getScheduleList(_ inProgress:((Double) -> ())?, completion:((NSError?) -> ())?) {
        guard currentSchedule != nil else { return }
        requestProgressUpdate = inProgress
        requestCompletion = completion
        SessionStore.sharedStore.runRequest(.scheduleList, withDelegate: self)
    }
    
    func cancelRequest(_ handler:(() -> ())?) {
        requestCanceled = handler
        SessionStore.sharedStore.cancelRequest()
    }
    
    func importSchedule(_ data:Data?) {
        guard let d = data else { return }
        
        let json = try! JSON(data: d)
        schedule.removeAll()
        print("Received \(json["Schedule"].count) Schedule Items")
        for (_,subJSON):(String,JSON) in json["Schedule"] {
            let scheduleItem = ScheduleItem(json: subJSON)
            schedule.append(scheduleItem)
        }
        schedule.sort(by: { $0.startTime!.compare($1.startTime! as Date) == .orderedAscending })
        print("Imported \(schedule.count) Schedule Items")
        _ = self.saveSchedule()
    }
    
    func buildMatchListForGroup(_ group:Int) {
        guard 1...7 ~= group && group != 4 else { return }
        var stationCode = (group & 4) > 0 ? "Blue" : "Red"
        stationCode += "\(group & 3)"
        var teamList:[MatchQueueData] = [MatchQueueData]()
        for item in schedule {
            let m = item.matchNumber
            for t in item.teams {
                if t.station == stationCode {
                    let data = MatchQueueData(match: m, team: t.teamNumber, alliance: (group & 4) > 0 ? .blue : .red)
                    teamList.append(data)
                }
            }
        }
        MatchStore.sharedStore.createMatchQueueFromMatchData(teamList)
    }
}

extension ScheduleStore: SessionStoreDelegate {
    func sessionStore(_ progress: Double, forRequest request: RequestType) {
        if request == .scheduleList {
            requestProgressUpdate?(progress)
        }
    }
    
    func sessionStoreCompleted(_ request: RequestType, withData data: Data?, andError error: NSError?) {
        if request == .scheduleList {
            if error != nil { currentSchedule = nil }
            requestCompletion?(error)
            importSchedule(data)
        }
        requestCompletion = nil
        requestProgressUpdate = nil
        requestCanceled = nil
    }
    
    func sessionStoreCanceled(_ request: RequestType) {
        if request == .scheduleList {
            currentSchedule = nil
            requestCanceled?()
        }
        requestCompletion = nil
        requestProgressUpdate = nil
        requestCanceled = nil
    }
}
