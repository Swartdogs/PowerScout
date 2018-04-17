//
//  MatchStore.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 2/6/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit

class MatchStore {
    
    // MARK: Properties
    
    var allMatches:[Match] = []
    var matchesToScout:[MatchQueueData] = []
    var currentMatchIndex = -1
    var currentMatch:MatchImpl?
    var fieldLayout:FieldLayoutType = .blueRed
    
    // Action Edit
    
    var actionsUndo:Stack<ActionEdit> = Stack<ActionEdit>(limit: 1)
    var actionsRedo:Stack<ActionEdit> = Stack<ActionEdit>(limit: 1)
    
    // MARK: Initialization
    
    init() {
        allMatches = []
        let matchData = NSKeyedUnarchiver.unarchiveObject(withFile: self.matchArchivePath) as? [MatchEncodingHelper] ?? [MatchEncodingHelper]()
        for helper in matchData {
            if let m = helper.match {
                allMatches.append(m)
            }
        }
        
        let queueData = NSKeyedUnarchiver.unarchiveObject(withFile: self.match2ScoutArchivePath) as? [NSDictionary]
        if let qD = queueData {
            for d in qD {
                if let mqd = MatchQueueData(propertyListRepresentation: d) {
                    matchesToScout.append(mqd)
                }
            }
        }
        
        if allMatches.count == 0 {
            print("No Match data existed!")
            allMatches = []
        } else {
            print("Match Data successfully Loaded")
        }
        
        let fieldLayout = UserDefaults.standard.integer(forKey: "SteamScout.fieldLayout")
        self.fieldLayout = FieldLayoutType(rawValue: fieldLayout)!
        
        currentMatch = nil
    }
    
    convenience init(withMock mock:Bool) {
        self.init()
        if mock {
            allMatches = [
                MatchImpl(queueData: MatchQueueData(match: 1, team: 1100, alliance: .red)),
                MatchImpl(queueData: MatchQueueData(match: 1, team: 1101, alliance: .red)),
                MatchImpl(queueData: MatchQueueData(match: 1, team: 1102, alliance: .red)),
                MatchImpl(queueData: MatchQueueData(match: 1, team: 1200, alliance: .blue)),
                MatchImpl(queueData: MatchQueueData(match: 1, team: 1201, alliance: .blue)),
                MatchImpl(queueData: MatchQueueData(match: 1, team: 1202, alliance: .blue)),
                MatchImpl(queueData: MatchQueueData(match: 2, team: 1300, alliance: .red)),
                MatchImpl(queueData: MatchQueueData(match: 2, team: 1301, alliance: .red)),
                MatchImpl(queueData: MatchQueueData(match: 2, team: 1302, alliance: .red)),
                MatchImpl(queueData: MatchQueueData(match: 2, team: 1400, alliance: .blue)),
                MatchImpl(queueData: MatchQueueData(match: 2, team: 1401, alliance: .blue)),
                MatchImpl(queueData: MatchQueueData(match: 2, team: 1402, alliance: .blue)),
                MatchImpl(queueData: MatchQueueData(match: 3, team: 1500, alliance: .red)),
                MatchImpl(queueData: MatchQueueData(match: 3, team: 1501, alliance: .red)),
                MatchImpl(queueData: MatchQueueData(match: 3, team: 1502, alliance: .red)),
                MatchImpl(queueData: MatchQueueData(match: 3, team: 1600, alliance: .blue)),
                MatchImpl(queueData: MatchQueueData(match: 3, team: 1601, alliance: .blue)),
                MatchImpl(queueData: MatchQueueData(match: 3, team: 1602, alliance: .blue)),
                MatchImpl(queueData: MatchQueueData(match: 4, team: 1700, alliance: .red)),
                MatchImpl(queueData: MatchQueueData(match: 4, team: 1701, alliance: .red)),
                MatchImpl(queueData: MatchQueueData(match: 4, team: 1702, alliance: .red)),
                MatchImpl(queueData: MatchQueueData(match: 4, team: 1800, alliance: .blue)),
                MatchImpl(queueData: MatchQueueData(match: 4, team: 1801, alliance: .blue)),
                MatchImpl(queueData: MatchQueueData(match: 4, team: 1802, alliance: .blue)),
                MatchImpl(queueData: MatchQueueData(match: 5, team: 1900, alliance: .red)),
                MatchImpl(queueData: MatchQueueData(match: 5, team: 1901, alliance: .red)),
                MatchImpl(queueData: MatchQueueData(match: 5, team: 1902, alliance: .red)),
                MatchImpl(queueData: MatchQueueData(match: 5, team: 2000, alliance: .blue)),
                MatchImpl(queueData: MatchQueueData(match: 5, team: 2001, alliance: .blue)),
                MatchImpl(queueData: MatchQueueData(match: 5, team: 2002, alliance: .blue))
            ]
            
            matchesToScout = []
            
            print("Mocking Match Data")
            
            self.fieldLayout = .blueRed
        }
    }
    
    // MARK: Archive Paths
    
    var matchArchivePath:String {
        let documentFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return (documentFolder as NSString).appendingPathComponent("Match.archive")
    }
    
    var match2ScoutArchivePath:String {
        let documentFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return (documentFolder as NSString).appendingPathComponent("MatchQueue.archive")
    }
    
    func filePath(_ filename:String) -> String {
        let documentFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return (documentFolder as NSString).appendingPathComponent(filename)
    }
    
    var csvFilePath:String {
        let documentFolder = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        return (documentFolder as NSString).appendingPathComponent("Match data - \(UIDevice.current.name).csv")
    }
    
    // MARK: Saving and Exporting
    
    // Return Values:
    // 0 - Success
    // 1 - MatchDataSave Failed
    // 2 - QueueDataSave Failed
    // 3 - Match+Queue Save Failed
    // 4 - CsvDataSave Failed
    // 5 - Csv+Match Save Failed
    // 6 - Csv+Queue Save Failed
    // 7 - Csv+Queue+Match Save Failed
    func saveChanges(withMatchType type: CsvDataProvider.Type) -> Int {
        UserDefaults.standard.set(fieldLayout.rawValue, forKey: "SteamScout.fieldLayout")

        let queueDataSave = saveMatchQueueData()
        
        let matchDataSave = saveMatchData()
        
        let csvDataSave = writeCSVFile(withType: type)
        
        return (matchDataSave ? 0 : 1) + (queueDataSave ? 0 : 2) + (csvDataSave ? 0 : 4)
    }
    
    func saveMatchQueueData() -> Bool {
        let path = self.match2ScoutArchivePath
        
        var queueData = [NSDictionary]()
        for mqd in matchesToScout {
            let d = mqd.propertyListRepresentation()
            queueData.append(d)
        }
        
        return NSKeyedArchiver.archiveRootObject(queueData, toFile: path)
    }
    
    func saveMatchData() -> Bool {
        let path = self.matchArchivePath
        
        var matchData = [MatchEncodingHelper]()
        for m in allMatches {
            matchData.append(m.encodingHelper)
        }
        
        return NSKeyedArchiver.archiveRootObject(matchData, toFile: path)
    }
    
    func writeCSVFile(withType type: CsvDataProvider.Type) -> Bool {
        let device = "\(UIDevice.current.name)    \r\n"
        var csvFileString = device
        
        csvFileString += type.csvHeader
        
        for m in allMatches {
            csvFileString += m.csvMatch + " \r\n"
        }
        
        do {
            try csvFileString.write(toFile: self.csvFilePath, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            return false
        }
        return true
    }
    
    func exportNewMatchData(withType type: CsvDataProvider.Type) -> Bool {
        
        let device = "\(UIDevice.current.name)  \r\n"
        var csvFileString = device
        var matchJSONData = [Dictionary<String, AnyObject>]();
        
        csvFileString += type.csvHeader
        
        for var m:Match in allMatches {
            if (m.isCompleted & 32) == 32 {
                m.isCompleted ^= 32
                csvFileString += m.csvMatch + " \r\n"
                matchJSONData.append(m.messageDictionary)
            }
        }
        
        do {
            try csvFileString.write(toFile: self.filePath("newMatchData.csv"), atomically: true, encoding: String.Encoding.utf8)
        } catch {
            return false
        }
        
        return saveChanges(withMatchType: type) == 0
    }
    
    // MARK: Match Creation
    
    func createMatch(_ returningType:MatchImpl.Type, onComplete handler:((Match) -> ())?) {
        currentMatch = returningType.init()
        currentMatchIndex = -1
        actionsUndo.clearAll()
        actionsRedo.clearAll()
        handler?(currentMatch!)
    }
    
    func createMatchFromQueueIndex(_ index:Int, withType returningType:MatchImpl.Type, onComplete handler:((Match) -> ())?) {
        guard 0..<matchesToScout.count ~= index else { return }
        let data = matchesToScout[index]
        currentMatch = returningType.init(queueData: data)
        currentMatchIndex = index
        actionsUndo.clearAll()
        actionsRedo.clearAll()
        handler?(currentMatch!)
    }
    
    func addMatch(_ newMatch:Match) {
        allMatches.append(newMatch)
    }
    
    func cancelCurrentMatchEdit() {
        currentMatch = nil
        currentMatchIndex = -1
        actionsUndo.clearAll()
        actionsRedo.clearAll()
    }
    
    func containsMatch(_ match:MatchImpl) -> Bool {
        for m in allMatches {
            guard let mm = m as? MatchImpl else { continue }
            if mm == match {
                return true
            }
        }
        return false
    }
    
    // MARK: Match Removal
    
    func removeMatchQueueAtIndex(_ index:Int) {
        guard 0..<matchesToScout.count ~= index else { return }
        matchesToScout.remove(at: index)
    }
    
    func removeMatchAtIndex(_ index:Int) -> Match? {
        guard 0..<allMatches.count ~= index else { return nil }
        return allMatches.remove(at: index)
    }
    
    func removeMatch(_ thisMatch:Match) {
        for (index, value) in allMatches.enumerated() {
            if value.teamNumber == thisMatch.teamNumber && value.matchNumber == thisMatch.matchNumber {
                allMatches.remove(at: index)
            }
        }
    }
    
    func replace(_ oldMatch:Match, withNewMatch newMatch:Match) {
        for (index, value) in allMatches.enumerated() {
            if value.teamNumber == oldMatch.teamNumber && value.matchNumber == oldMatch.matchNumber {
                allMatches[index] = newMatch
            }
        }
    }
    
    // MARK: Update Matches
    
    func updateCurrentMatchForType(_ type:UpdateType, match:Match) {
        currentMatch?.updateForType(type, withMatch: match)
    }
    
    func updateCurrentMatchWithAction(_ action:Action) {
        guard let cm:Actionable = currentMatch as? Actionable else { return }
        cm.updateMatchWithAction(action)
    }
    
    func finishCurrentMatch() {
        currentMatch!.aggregateMatchData()
        allMatches.append(currentMatch!)
        if currentMatchIndex >= 0 {
            matchesToScout.remove(at: currentMatchIndex)
        }
        currentMatchIndex = -1
        let success = self.saveChanges(withMatchType: type(of: currentMatch!))
        print("All Matches were \(success == 0 ? "" : "un")successfully saved")
        currentMatch = nil
    }
    
    func dataTransferMatchesAll(_ all:Bool) -> Data? {
        var matchData = [Dictionary<String, AnyObject>]()
        
        for match in allMatches {
            if match.selectedForDataTransfer {
                matchData.append(match.messageDictionary)
            }
        }
        
        return try? JSONSerialization.data(withJSONObject: matchData)
    }
    
    func dataTransferComplete() {
        for var match in allMatches {
            if match.selectedForDataTransfer {
                match.selectedForDataTransfer = false
                match.lastExportedByXfer = Date()
                //match.shouldExport = match.lastExportedByXfer == nil
            }
        }
    }
    
    func dataTransferImport(matches: [Match]) {
        for match in matches {
            if let onFile = allMatches.first(where: { return $0.teamNumber == match.teamNumber && $0.matchNumber == match.matchNumber }) {
                print("Same Match Detected!\nReceived: ")
                // TODO: Print match diff (need a method for that)
                print(match.messageDictionary)
                print("On file:")
                print(onFile.messageDictionary)
            }
            print("Adding Match")
            allMatches.append(match)
        }
    }
    
    func createMatchQueueFromMatchData(_ data:[MatchQueueData]) {
        guard data.count > 0 else { return }
        
        matchesToScout.removeAll()
        matchesToScout = data
        _ = self.saveMatchQueueData()
    }
    
    func clearMatchData(_ type:Int) {
        if type & 1 == 1 {
            matchesToScout.removeAll()
        }
        
        if type & 2 == 2 {
            allMatches.removeAll()
        }
    }
}
