//
//  DebugDataTransferViewController.swift
//  PowerScout
//
//  Created by Srinivas Dhanwada on 1/29/18.
//  Copyright © 2018 FRC Team 525. All rights reserved.
//

import UIKit
import MBProgressHUD
import MultipeerConnectivity

class DebugDataTransferViewController: DataTransferViewController {
    @IBOutlet var sendAdvertProceed: UIButton!
    @IBOutlet var sendAdvertGoBack: UIButton!
    @IBOutlet var sendAdvertErrorOut: UIButton!
    @IBOutlet var sendBrowseProceed: UIButton!
    @IBOutlet var sendBrowseGoBack: UIButton!
    @IBOutlet var sendBrowseErrorOut: UIButton!
    @IBOutlet var sendReset: UIButton!
    @IBOutlet var sendPing: UIButton!
    @IBOutlet var serviceStateLabel: UILabel!
    @IBOutlet var sessionStateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        serviceStore.delegate = self
        setServiceStateLabel(for: serviceStore.machineState)
        setSessionStateLabel(for: serviceStore.sessionState)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction override func handleButtonSelect(_ sender: UIButton) {
        switch sender {
        case sendAdvertProceed:
            serviceStore.proceedWithAdvertising()
            break
        case sendAdvertGoBack:
            serviceStore.goBackWithAdvertising()
            break
        case sendAdvertErrorOut:
            serviceStore.errorOutWithAdvertising()
            break
        case sendBrowseProceed:
            serviceStore.proceedWithBrowsing()
            break
        case sendBrowseGoBack:
            serviceStore.goBackWithBrowsing()
            break
        case sendBrowseErrorOut:
            serviceStore.errorOutWithBrowsing()
            break
        case sendReset:
            serviceStore.resetStateMachine()
            break
        default:
            break
        }
    }
    
    override func sendData() {
        serviceStore.sendMessage("ping")
        serviceStore.sendMessage("EOD")
    }
    
    @IBAction func pingConnectedDevices(_ sender: UIButton) {
        let message = "ping"
        serviceStore.sendMessage(message)
        serviceStore.sendMessage("EOD")
    }
    
    @IBAction override func unwindToDataTransferView(_ sender:UIStoryboardSegue) {
        print(String(describing: sender.identifier));
        AppUtility.revertOrientation()
        
        if let id = sender.identifier {
            if id.elementsEqual("UnwindSegueDoneSelectingData") {
                print("Data Selection Complete")
                serviceStore.proceedWithAdvertising()
            } else if id.elementsEqual("UnwindSegueCancelSelectingData") {
                print("Data Selection Canceled")
                serviceStore.goBackWithAdvertising()
            } else if id.elementsEqual("UnwindSegueDoneFromBrowser") {
                print("Browser Selection Done")
                if let sd = selectedDevice {
                    serviceStore.proceedWithBrowsing(andSelectDevice: sd)
                }
            } else if id.elementsEqual("UnwindSegueCancelFromBrowser") {
                print("resetting delegate")
                self.delegate = nil
                serviceStore.goBackWithBrowsing()
            }
        }
    }
    
    override func updateUI(includeButtons buttons: Bool, includeLabels labels: Bool, includeSwitches switches: Bool) {
        if buttons {
            updateButtonStates()
        }
        
        if labels {
            setSessionStateLabel(for: serviceStore.sessionState)
            setServiceStateLabel(for: serviceStore.machineState)
        }
    }
    
    func updateButtonStates() {
        let advertising = serviceStore.advertising
        let browsing = serviceStore.browsing
        
        sendPing.isEnabled = serviceStore.machineState == .advertSendingData
        
        sendAdvertProceed.isEnabled = advertising || !browsing
        sendAdvertGoBack.isEnabled = advertising || !browsing
        sendAdvertErrorOut.isEnabled = advertising || !browsing
        
        sendBrowseProceed.isEnabled = browsing || !advertising
        sendBrowseGoBack.isEnabled = browsing || !advertising
        sendBrowseErrorOut.isEnabled = browsing || !advertising
    }
    
    func setSessionStateLabel(for state: MCSessionState) {
        switch state {
        case .notConnected:
            sessionStateLabel.text = "Not Connected"
            break
        case .connecting:
            sessionStateLabel.text = "Connecting"
            break
        case .connected:
            sessionStateLabel.text = "Connected"
            break
        }
    }
    
    func setServiceStateLabel(for state: ServiceState) {
        serviceStateLabel.text = String(describing: state)
    }
}
