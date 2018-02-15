//
//  ServiceStoreDelegate.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 8/23/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol ServiceStoreDelegate: class {
    func serviceStore(_ serviceStore:ServiceStore, withSession session:MCSession, didChangeState state:MCSessionState)
    func serviceStore(_ serviceStore:ServiceStore, didReceiveData data:Data, fromDevice device:NearbyDevice)
    func serviceStore(_ serviceStore:ServiceStore, transitionedFromState fromState:ServiceState, toState:ServiceState, forEvent event:ServiceEvent, withUserInfo userInfo:Any?)
    
    func serviceStore(_ serviceStore:ServiceStore, foundNearbyDevice device:NearbyDevice);
    func serviceStore(_ serviceStore:ServiceStore, lostNearbyDevice device:NearbyDevice);
    
}
