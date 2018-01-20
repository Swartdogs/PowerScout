//
//  EventStore.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/17/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit
import SwiftyJSON

enum EventFilterType {
    case none, type, country
}

class EventStore: NSObject {

    static let sharedStore = EventStore()
    
    var allEvents:[Event] = [Event]()
    var eventsByType:[[Event]] = [[Event]]()
    var selectedEvent:Event? {
        didSet {
            if selectedEvent == nil {
                UserDefaults.standard.setNilValueForKey("SteamScout.selectedEvent")
            } else {
                let data = NSKeyedArchiver.archivedData(withRootObject: selectedEvent!)
                UserDefaults.standard.setValue(data, forKey: "SteamScout.selectedEvent")
            }
        }
    }
    
    var requestProgressUpdate:((Double) -> ())? = nil
    var requestCompletion:((NSError?) -> ())? = nil
    var requestCanceled:(() -> ())? = nil
    
    
    fileprivate override init() {
        super.init()
        
        //let eventsArchive = NSKeyedUnarchiver.unarchiveObjectWithFile(self.eventArchivePath()) as? [Event]
        let eventDataAsset = NSDataAsset(name: "Events")
        if let eda = eventDataAsset {
            let eventsArchive = NSKeyedUnarchiver.unarchiveObject(with: eda.data) as? [Event]
            allEvents = eventsArchive ?? allEvents
        }
        let data = UserDefaults.standard.value(forKey: "SteamScout.selectedEvent") as? Data
        if data != nil {
            self.selectedEvent = NSKeyedUnarchiver.unarchiveObject(with: data!) as? Event
        }
        
        createEventByType()
    }
    
    func saveEventList() -> Bool {
        let path = eventArchivePath()
        return NSKeyedArchiver.archiveRootObject(allEvents, toFile: path)
    }
    
    func eventArchivePath() -> String {
        let documentFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return (documentFolder as NSString).appendingPathComponent("Events.archive")
    }
    
    func getEventsList(_ inProgress:((Double) -> ())?, completion:((NSError?) -> ())?) {
        requestProgressUpdate = inProgress
        requestCompletion = completion
        SessionStore.sharedStore.runRequest(.eventList, withDelegate: self)
    }
    
    func cancelRequest(_ handler:(() -> ())?) {
        requestCanceled = handler
        SessionStore.sharedStore.cancelRequest()
    }
    
    func importEventsList(_ data:Data?) {
        guard let d = data else { return }
        
        let json = try! JSON(data: d)
        if json["eventCount"].intValue == 0 {
            print("Error in receiving events: \(json[0].error)")
            return
        }
        print("Receieved \(json["eventCount"].intValue) events")
        allEvents.removeAll()
        for (_,subJson):(String,JSON) in json["Events"] {
            let event = Event(json: subJson)
            allEvents.append(event)
        }
        createEventByType()
        _ = saveEventList()
    }
    
    func filterEventsBy(_ type:EventFilterType, compareValue:AnyObject) -> [Event] {
        let cVal = compareValue as! String
        let filteredEvents = allEvents.filter({event in event.type == cVal})
        print("There are only \(filteredEvents.count) in the filtered Array")
        return filteredEvents
    }
    
    func createEventByType() {
        if allEvents.count < 0 {
            return
        }
        
        var regionals = [Event]()
        var districtEvent = [Event]()
        var districtChampionship = [Event]()
        var championshipSubdivision = [Event]()
        var championshipDivision = [Event]()
        var championship = [Event]()
        var offseason = [Event]()
        
        for event in allEvents {
            if event.type == "Regional" {
                regionals.append(event)
            } else if event.type == "DistrictEvent" {
                districtEvent.append(event)
            } else if event.type == "DistrictChampionship" {
                districtChampionship.append(event)
            } else if event.type == "ChampionshipSubdivision" {
                championshipSubdivision.append(event)
            } else if event.type == "ChampionshipDivision" {
                championshipDivision.append(event)
            } else if event.type == "Championship" {
                championship.append(event)
            } else if event.type == "OffSeason" {
                offseason.append(event)
            }
        }
        
        regionals.sort(by: {$0.dateStart!.compare($1.dateStart! as Date) == .orderedAscending})
        districtEvent.sort(by: {$0.dateStart!.compare($1.dateStart! as Date) == .orderedAscending})
        districtChampionship.sort(by: {$0.dateStart!.compare($1.dateStart! as Date) == .orderedAscending})
        championshipSubdivision.sort(by: {$0.dateStart!.compare($1.dateStart! as Date) == .orderedAscending})
        championshipDivision.sort(by: {$0.dateStart!.compare($1.dateStart! as Date) == .orderedAscending})
        championship.sort(by: {$0.dateStart!.compare($1.dateStart! as Date) == .orderedAscending})
        offseason.sort(by: {$0.dateStart!.compare($1.dateStart! as Date) == .orderedAscending})
        
        self.eventsByType = [regionals,
                             districtEvent,
                             districtChampionship,
                             championshipSubdivision,
                             championshipDivision,
                             championship,
                             offseason]
        
        print("There were \(eventsByType.count) event types imported")
    }
    
    func eventHeaderForSection(_ section:Int) -> String {
        return section == 0 ? "Regional"                 :
               section == 1 ? "District Event"           :
               section == 2 ? "District Championship"    :
               section == 3 ? "Championship Subdivision" :
               section == 4 ? "Championship Division"    :
               section == 5 ? "Championship"             :
               section == 6 ? "OffSeason"                : ""
    }
}

extension EventStore: SessionStoreDelegate {
    func sessionStore(_ progress: Double, forRequest request: RequestType) {
        if request == .eventList {
            requestProgressUpdate?(progress)
        }
    }
    
    func sessionStoreCompleted(_ request: RequestType, withData data: Data?, andError error: NSError?) {
        if request == .eventList {
            requestCompletion?(error)
            if let d = data {
                importEventsList(d)
            }
        }
        requestCanceled = nil
        requestCompletion = nil
        requestProgressUpdate = nil
    }
    
    func sessionStoreCanceled(_ request: RequestType) {
        if request == .eventList {
            requestCanceled?()
        }
        requestCanceled = nil
        requestCompletion = nil
        requestProgressUpdate = nil
    }
}
