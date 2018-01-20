//
//  AppUtility.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/16/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import UIKit

struct AppUtility {
    
    static var lastOrientation:UIInterfaceOrientation = UIInterfaceOrientation.unknown
    static func lockOrientation(to orientation: UIInterfaceOrientationMask) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
            lastOrientation = UIApplication.shared.statusBarOrientation
        }
    }
    
    static func revertOrientation() {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = (AppUtility.lastOrientation == .landscapeLeft || AppUtility.lastOrientation == .landscapeRight) ? UIInterfaceOrientationMask.landscape : UIInterfaceOrientationMask.all
        }
    }
    
    static func unlockOrientation() {
        lockOrientation(to: .all)
    }
}
