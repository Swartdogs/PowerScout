//
//  UINavigationController+Rotation.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/15/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import UIKit

class RotationNavigationController: UINavigationController {
    override var shouldAutorotate: Bool {
        return visibleViewController?.shouldAutorotate ?? true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
       return visibleViewController?.supportedInterfaceOrientations ?? .all
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return visibleViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
    }
}
