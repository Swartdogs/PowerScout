//
//  SessionStore.swift
//  StrongScout
//
//  Created by Srinivas Dhanwada on 3/17/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit
import SwiftyJSON

enum RequestType: Int {
    case none = 0, eventList, scheduleList
    
    var url : String {
        switch(self) {
        case .eventList:
            return "https://frc-api.firstinspires.org/v2.0/2017/events?exludeDistrict=false"
        case .scheduleList:
            return "https://frc-api.firstinspires.org/v2.0/2017/schedule/\(ScheduleStore.sharedStore.currentSchedule!)?tournamentLevel=qual"
        default:
            return ""
        }
    }
}

protocol SessionStoreDelegate: class {
    func sessionStoreCompleted(_ request:RequestType, withData data:Data?, andError error:NSError?)
    func sessionStoreCanceled(_ request:RequestType)
    func sessionStore(_ progress:Double, forRequest request:RequestType)
}

class SessionStore: NSObject {
    static let sharedStore:SessionStore = SessionStore()
    
    fileprivate weak var delegate:SessionStoreDelegate?
    
    fileprivate var sessionConfig:URLSessionConfiguration!
    fileprivate var currentRequest:RequestType = .none
    fileprivate var currentTask:URLSessionDownloadTask? = nil
    
    fileprivate override init() {
        super.init()
        
        sessionConfig = URLSessionConfiguration.default
        
        sessionConfig.httpAdditionalHeaders = ["Accept":"application/json", "Authorization":"Basic UHJpc006MTFEQTAwRDAtNUQ4Ri00RUUxLTg2OTItNDI4MEI4RENBQjFB"]
        sessionConfig.httpMaximumConnectionsPerHost = 1
        sessionConfig.timeoutIntervalForRequest = 30.0
    }
    
    func getEventList(delegate:SessionStoreDelegate?) {
        self.delegate = delegate
        let url = URL(string: "https://frc-api.firstinspires.org/v2.0/2016/events?exludeDistrict=false")!
        let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        let request = URLRequest(url: url)
        let task = session.downloadTask(with: request)
        
        task.resume()
    }
    
    func runRequest(_ type:RequestType, withDelegate delegate:SessionStoreDelegate?) {
        guard currentTask == nil else { return }
        self.delegate = delegate
        self.currentRequest = type
        let url = URL(string: self.currentRequest.url)!
        let session = Foundation.URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        let request = URLRequest(url: url);
        
        currentTask = session.downloadTask(with: request)
        
        // Swift 3
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: { [weak self] in
            self?.currentTask?.resume()
        })
        
        currentTask!.resume()
    }
    
    func cancelRequest() {
        guard currentTask != nil else { return }
        currentTask!.cancel()
    }
    
    fileprivate func sessionCompleteCleanup(_ data:Data?, error:NSError?) {
        if let d = delegate {
            d.sessionStoreCompleted(self.currentRequest, withData: data, andError: error)
        }
        delegate = nil
        self.currentRequest = .none
        self.currentTask = nil
    }
}

extension SessionStore: URLSessionDelegate {
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        if let error = error {
            print("\(session) did become invalid with error: \(error)")
        }
        if let d = delegate {
            d.sessionStoreCanceled(self.currentRequest)
        }
        delegate = nil
        self.currentRequest = .none
        self.currentTask = nil
    }
}

extension SessionStore: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("\(session), \(task) did complete with error \(error)")
        if error == nil {
            self.sessionCompleteCleanup(nil, error: nil)
        } else if (error as! NSError).userInfo[NSLocalizedDescriptionKey] as! String == "cancelled" {
            if let d = delegate {
                d.sessionStoreCanceled(self.currentRequest)
            }
            delegate = nil
            self.currentRequest = .none
            self.currentTask = nil
        } else {
            self.sessionCompleteCleanup(nil, error: error as NSError?)
        }
    }
}

extension SessionStore: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        if let d = delegate {
            d.sessionStore(progress, forRequest: self.currentRequest)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let data = try? Data(contentsOf: location)
        self.sessionCompleteCleanup(data, error: nil)
    }
}
