//
//  ViewController.swift
//  PowerScoutDebugging
//
//  Created by Srinivas Dhanwada on 2/13/18.
//  Copyright © 2018 FRC Team 525. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var matchStore:MatchStore!
    var serviceStore:ServiceStore!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            matchStore = delegate.matchStore
            serviceStore = delegate.serviceStore
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindToMatchView(_ sender:UIStoryboardSegue) {
        AppUtility.revertOrientation()
    }
    
    @IBAction func unwindToCompletedMatchView(_ sender:UIStoryboardSegue) {
        AppUtility.revertOrientation()
    }

    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            if id.elementsEqual("SegueToDataEntry") {
                self.matchStore.createMatch(PowerMatch.self, onComplete:nil)
                if let nc = segue.destination as? UINavigationController,
                    let vc = nc.topViewController as? DataEntryViewController {
                    vc.matchStore = matchStore
                }
            } else if id.elementsEqual("SegueToDebugTransfer") {
                if let vc = segue.destination as? DebugDataTransferViewController {
                    vc.matchStore = matchStore
                    vc.serviceStore = serviceStore
                    serviceStore.resetStateMachine()
                    serviceStore.delegate = vc
                    
                    vc.transferMode = .doNothing
                }
            } else if id.elementsEqual("SegueToTransfer") {
                if let vc = segue.destination as? DataTransferViewController {
                    vc.matchStore = matchStore
                    vc.serviceStore = serviceStore
                    serviceStore.resetStateMachine()
                    serviceStore.delegate = vc
                    
                    vc.transferMode = .doNothing
                }
            }
        }
    }
}

