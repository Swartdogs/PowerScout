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
        ServiceStore.shared.delegate = self
        setServiceStateLabel(for: ServiceStore.shared.machineState)
        setSessionStateLabel(for: ServiceStore.shared.sessionState)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        ServiceStore.shared.delegate = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction override func handleButtonSelect(_ sender: UIButton) {
        switch sender {
        case sendAdvertProceed:
            ServiceStore.shared.proceedWithAdvertising()
            break
        case sendAdvertGoBack:
            ServiceStore.shared.goBackWithAdvertising()
            break
        case sendAdvertErrorOut:
            ServiceStore.shared.errorOutWithAdvertising()
            break
        case sendBrowseProceed:
            ServiceStore.shared.proceedWithBrowsing()
            break
        case sendBrowseGoBack:
            ServiceStore.shared.goBackWithBrowsing()
            break
        case sendBrowseErrorOut:
            ServiceStore.shared.errorOutWithBrowsing()
            break
        case sendReset:
            ServiceStore.shared.resetStateMachine()
            break
        default:
            break
        }
    }
    
    override func sendData() {
        ServiceStore.shared.sendMessage("ping")
        ServiceStore.shared.sendMessage("EOD")
    }
    
    @IBAction func pingConnectedDevices(_ sender: UIButton) {
        let message = "ping"
        ServiceStore.shared.sendMessage(message)
        ServiceStore.shared.sendMessage("EOD")
    }
    
    @IBAction override func unwindToDataTransferView(_ sender:UIStoryboardSegue) {
        print(String(describing: sender.identifier));
        AppUtility.revertOrientation()
        
        if let id = sender.identifier {
            if id.elementsEqual("UnwindSegueDoneSelectingData") {
                print("Data Selection Complete")
                ServiceStore.shared.proceedWithAdvertising()
            } else if id.elementsEqual("UnwindSegueCancelSelectingData") {
                print("Data Selection Canceled")
                ServiceStore.shared.goBackWithAdvertising()
            } else if id.elementsEqual("UnwindSegueDoneFromBrowser") {
                print("Browser Selection Done")
                if let sd = selectedDevice {
                    ServiceStore.shared.proceedWithBrowsing(andSelectDevice: sd)
                }
            } else if id.elementsEqual("UnwindSegueCancelFromBrowser") {
                print("resetting delegate")
                self.delegate = nil
                ServiceStore.shared.goBackWithBrowsing()
            }
        }
    }
    
    override func updateUI(includeButtons buttons: Bool, includeLabels labels: Bool, includeSwitches switches: Bool) {
        if buttons {
            updateButtonStates()
        }
        
        if labels {
            setSessionStateLabel(for: ServiceStore.shared.sessionState)
            setServiceStateLabel(for: ServiceStore.shared.machineState)
        }
    }
    
    func updateButtonStates() {
        let advertising = ServiceStore.shared.advertising
        let browsing = ServiceStore.shared.browsing
        
        sendPing.isEnabled = ServiceStore.shared.machineState == .advertSendingData
        
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
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier!.elementsEqual("SegueToBrowser") {
            if let nav = segue.destination as? UINavigationController {
                if let vc = nav.topViewController as? NearbyDevicesTableViewController {
                    self.delegate = vc
                }
            }
        }
    }
}
