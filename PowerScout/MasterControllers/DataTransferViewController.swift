//
//  DataTransferViewController.swift
//  PowerScout
//
//  Created by Srinivas Dhanwada on 1/23/18.
//  Copyright © 2018 FRC Team 525. All rights reserved.
//

import UIKit
import MBProgressHUD
import MultipeerConnectivity

enum DataTransferMode {
    case doNothing
    case advertise
    case browse
}

protocol DataTransferViewControllerDelegate: class {
    func dataTransferViewController(_ dataTransferViewController: DataTransferViewController, foundNearbyDevice nearbyDevice: NearbyDevice)
    func dataTransferViewController(_ dataTransferViewController: DataTransferViewController, lostNearbyDevice nearbyDevice: NearbyDevice)
}

class DataTransferViewController: UIViewController, ServiceStoreDelegate {
    
    @IBOutlet var advertSwitch: UISwitch!
    @IBOutlet var browseSwitch: UISwitch!
    
    @IBOutlet var proceed: UIButton!
    @IBOutlet var goBack: UIButton!
    @IBOutlet var reset: UIButton!
    
    @IBOutlet var statusLabel: UILabel!
    
    weak var delegate:DataTransferViewControllerDelegate?
    var selectedDevice: NearbyDevice?
    var transferMode: DataTransferMode = .doNothing
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ServiceStore.shared.resetStateMachine()
        ServiceStore.shared.delegate = self
        
        transferMode = .doNothing
        updateUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        ServiceStore.shared.delegate = nil
        ServiceStore.shared.resetStateMachine()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: IBAction
    
    @IBAction func handleSwitchChange(_ sender: UISwitch) {
        switch sender {
        case advertSwitch:
            if transferMode == .browse {
                ServiceStore.shared.resetStateMachine()
            }
            transferMode = advertSwitch.isOn ? .advertise : .doNothing
            updateUI()
            break
        case browseSwitch:
            if transferMode == .advertise {
                ServiceStore.shared.resetStateMachine()
            }
            transferMode = browseSwitch.isOn ? .browse : .doNothing
            updateUI()
            break
        default:
            break
        }
    }
    
    @IBAction func handleButtonSelect(_ sender: UIButton) {
        switch sender {
        case proceed:
            if transferMode == .advertise {
                ServiceStore.shared.proceedWithAdvertising()
            } else if transferMode == .browse {
                ServiceStore.shared.proceedWithBrowsing()
            }
            break
        case goBack:
            if transferMode == .advertise {
                ServiceStore.shared.goBackWithAdvertising()
            } else if transferMode == .browse {
                ServiceStore.shared.goBackWithBrowsing()
            }
            break
        case reset:
            ServiceStore.shared.resetStateMachine()
            break
        default:
            break
        }
    }
    
    @IBAction func unwindToDataTransferView(_ sender:UIStoryboardSegue) {
        print(String(describing: sender.identifier));
        AppUtility.revertOrientation()
        
        if let id = sender.identifier {
            if id.elementsEqual("UnwindSegueDoneSelectingData") {
                print("Data Selection Complete")
                if let vc = sender.source as? DataSelectionViewController {
                    let selectedMatches = vc.selectedMatches
                    print("Selected Matches count: \(selectedMatches.count)")
                }
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
    
    // MARK: Public Functions
    
    func updateUI(includeButtons buttons: Bool = true, includeLabels labels: Bool = true, includeSwitches switches: Bool = true) {
        if buttons {
            proceed.isEnabled = transferMode != .doNothing
            goBack.isEnabled = transferMode != .doNothing
        }
        
        if labels {
            updateStatusLabel()
        }
        
        if switches {
            advertSwitch.isOn = transferMode == .advertise
            browseSwitch.isOn = transferMode == .browse
        }
    }
    
    func updateStatusLabel() {
        proceed.isEnabled = true
        goBack.isEnabled = true
        switch ServiceStore.shared.machineState {
        case .notReady:
            statusLabel.text = "Ready to Start"
            goBack.setTitle("Go Back", for: .normal)
            goBack.isEnabled = false
            if transferMode == .advertise {
                proceed.setTitle("Select Data", for: .normal)
            } else if transferMode == .browse {
                proceed.setTitle("Start Browser", for: .normal)
            } else {
                proceed.setTitle("Proceed", for: .normal)
                proceed.isEnabled = false
            }
            break
        case .advertSelectingData:
            statusLabel.text = "Selecting Data"
            proceed.setTitle("Advertise", for: .normal)
            proceed.isEnabled = false
            goBack.setTitle("Go Back", for: .normal)
            break
        case .advertReady:
            statusLabel.text = "Ready to Advertise"
            proceed.setTitle("Advertise", for: .normal)
            goBack.setTitle("Select Data", for: .normal)
            break
        case .advertRunning:
            statusLabel.text = "Advertising"
            proceed.setTitle("Proceed", for: .normal)
            proceed.isEnabled = false
            goBack.setTitle("Stop", for: .normal)
            break
        case .advertInvitationPending:
            statusLabel.text = "Invitation Pending"
            proceed.setTitle("Proceed", for: .normal)
            proceed.isEnabled = false
            goBack.setTitle("Go Back", for: .normal)
            goBack.isEnabled = false
            break
        case .advertConnecting:
            statusLabel.text = "Connecting to Browser"
            proceed.setTitle("Proceed", for: .normal)
            proceed.isEnabled = false
            goBack.setTitle("Go Back", for: .normal)
            goBack.isEnabled = false
            break
        case .advertSendingData:
            statusLabel.text = "Sending Data"
            proceed.setTitle("Proceed", for: .normal)
            proceed.isEnabled = false
            goBack.setTitle("Go Back", for: .normal)
            goBack.isEnabled = false
            break
        case .browseRunning:
            statusLabel.text = "Browsing"
            proceed.setTitle("Proceed", for: .normal)
            proceed.isEnabled = false
            goBack.setTitle("Stop", for: .normal)
            break
        case .browseInvitationPending:
            statusLabel.text = "Invitation Pending"
            proceed.setTitle("Proceed", for: .normal)
            proceed.isEnabled = false
            goBack.setTitle("Go Back", for: .normal)
            goBack.isEnabled = false
            break
        case .browseConnecting:
            statusLabel.text = "Connecting to Advertiser"
            proceed.setTitle("Proceed", for: .normal)
            proceed.isEnabled = false
            goBack.setTitle("Go Back", for: .normal)
            goBack.isEnabled = false
            break
        case .browseReceivingData:
            statusLabel.text = "Receiving Data"
            proceed.setTitle("Proceed", for: .normal)
            proceed.isEnabled = false
            goBack.setTitle("Go Back", for: .normal)
            goBack.isEnabled = false
            break
        }
    }
    
    func sendData() {
        if let matchData = MatchStore.sharedStore.dataTransferMatchesAll(true) {
            ServiceStore.shared.sendData(matchData)
        }
        ServiceStore.shared.sendMessage("EOD")
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            if identifier.elementsEqual("SegueToBrowser") {
                if let nav = segue.destination as? UINavigationController {
                    if let vc = nav.topViewController as? NearbyDevicesTableViewController {
                        self.delegate = vc
                    }
                }
            }
        }
    }
    
    // MARK: - ServiceStoreDelegate
    
    func serviceStore(_ serviceStore: ServiceStore, withSession session: MCSession, didChangeState state: MCSessionState) {
        print("ServiceStore Session: \(session.debugDescription) did change state: \(state)")
        
        DispatchQueue.main.async {
            self.updateUI(includeButtons: false, includeSwitches: false)
        }
    }
    
    func serviceStore(_ serviceStore: ServiceStore, withSession session: MCSession, didReceiveData data: Data, fromPeer peerId: MCPeerID) {
        if let message = String(data: data, encoding: .utf8) {
            print("Message decoded: \(message)")
            if message == "ping" {
                DispatchQueue.main.async { [weak self] in
                    let alert = UIAlertController(title: "Ping!", message: "\(peerId.displayName) pinged you!", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alert.addAction(ok)
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
        
        let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
        if let jsonData = json as? [Dictionary<String, AnyObject>] {
            var matches = [Match]();
            for matchData in jsonData {
                matches.append(MatchImpl(withPList: matchData))
            }
            
            print("Matches Count: \(matches.count)")
            MatchStore.sharedStore.dataTransferImport(matches: matches)
        }
    }
    
    func serviceStore(_ serviceStore: ServiceStore, withBrowser browser: MCNearbyServiceBrowser, foundPeer peerId: MCPeerID) {
        print("found peer: \(peerId.displayName)")
        if delegate != nil {
            delegate?.dataTransferViewController(self, foundNearbyDevice: NearbyDevice(displayName: peerId.displayName, type: .multipeerConnectivity))
        }
    }
    
    func serviceStore(_ serviceStore: ServiceStore, withBrowser browser: MCNearbyServiceBrowser, lostPeer peerId: MCPeerID) {
        print("lost peer: \(peerId.displayName)")
        if delegate != nil {
            delegate?.dataTransferViewController(self, lostNearbyDevice: NearbyDevice(displayName: peerId.displayName, type: .multipeerConnectivity))
        }
    }
    
    func serviceStore(_ serviceStore: ServiceStore, transitionedFromState fromState: ServiceState, toState: ServiceState, forEvent event: ServiceEvent, withUserInfo userInfo: Any?) {
        // TODO: Implement Further
        
        switch(event, fromState, toState) {
        // State Updates (no further action required)
        case (.advertProceed, .advertReady, .advertRunning) :
            print("Advertiser Started")
            break
        case (.advertGoBack, .advertRunning, .advertReady) :
            print("Advertiser Stopped")
            break
        case (.browseProceed, .notReady, .browseRunning) :
            print("Browser Started")
            fallthrough
        case (.browseGoBack, .browseInvitationPending, .browseRunning) : fallthrough
        case (.browseGoBack, .browseConnecting, .browseRunning) : fallthrough
        case (.browseGoBack, .browseReceivingData, .browseRunning) :
            self.performSegue(withIdentifier: "SegueToBrowser", sender: self)
            break
        case (.browseGoBack, .browseRunning, .notReady) :
            print("Browser Stopped")
            break
        case (.reset, .advertSelectingData, .notReady)      : fallthrough
        case (.reset, .advertReady, .notReady)              : fallthrough
        case (.reset, .advertRunning, .notReady)            : fallthrough
        case (.reset, .advertInvitationPending, .notReady)  : fallthrough
        case (.reset, .advertConnecting, .notReady)         : fallthrough
        case (.reset, .advertSendingData, .notReady)        : fallthrough
        case (.reset, .browseRunning, .notReady)            : fallthrough
        case (.reset, .browseInvitationPending, .notReady)  : fallthrough
        case (.reset, .browseConnecting, .notReady)         : fallthrough
        case (.reset, .browseReceivingData, .notReady)      : fallthrough
        case (.reset, .notReady, .notReady)                 :
            print("Reset Event Ocurred")
            break
            
        // UI Updates (need to update UI on main thread)
        case (.advertProceed, .notReady, .advertSelectingData) : fallthrough
        case (.advertGoBack, .advertReady, .advertSelectingData) :
            print("Show Data Selection Screen UI")
            
            self.performSegue(withIdentifier: "SegueToDataSelection", sender: self)
            
            break
        case (.advertProceed, .advertSelectingData, .advertReady) : fallthrough
        case (.advertGoBack,  .advertSelectingData, .notReady) :
            print("Hide Data Selection Screen UI")
            break
        case (.advertProceed, .advertRunning, .advertInvitationPending) : fallthrough
        case (.browseProceed, .browseRunning, .browseInvitationPending) :
            print("Show Invitation Pending UI")
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: false)
                let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                hud.mode = .indeterminate
                hud.label.text = "Invitation Pending"
                hud.hide(animated: true, afterDelay: 2)
            }
            break
        case (.advertProceed, .advertInvitationPending, .advertConnecting) : fallthrough
        case (.browseProceed, .browseInvitationPending, .browseConnecting) :
            print("Show Connecting UI")
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: false)
                let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                hud.mode = .indeterminate
                hud.label.text = "Connecting"
                hud.hide(animated: true, afterDelay: 2)
            }
            break
        case (.advertProceed, .advertConnecting, .advertSendingData) :
            print("Show Sending Data UI")
            sendData()
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: false)
                let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                hud.mode = .indeterminate
                hud.label.text = "Sending Data"
                hud.hide(animated: true, afterDelay: 2)
            }
            break
        case (.browseProceed, .browseConnecting, .browseReceivingData) :
            print("Show Receiving Data UI")
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: false)
                let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                hud.mode = .indeterminate
                hud.label.text = "Receiving Data"
                hud.hide(animated: true, afterDelay: 2)
            }
            
            break
        case (.advertProceed, .advertSendingData, .notReady) :
            MatchStore.sharedStore.dataTransferComplete()
            fallthrough
        case (.browseProceed, .browseReceivingData, .notReady) :
            print("Show Complete UI and hide after 2 sec delay")
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: false)
                let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                let imageView = UIImageView(image: UIImage(named: "Check"))
                hud.mode = .customView
                hud.customView = imageView
                hud.label.text = "Completed"
                hud.hide(animated: true, afterDelay: 2)
            }
            break
        case (.advertGoBack, .advertInvitationPending, .advertRunning) : fallthrough
        case (.advertGoBack, .advertConnecting, .advertRunning) : fallthrough
        case (.advertGoBack, .advertSendingData, .advertRunning) :
            // UI Might not be necesssary
            print("Show Dismissal UI with userInfo: \(String(describing: userInfo))")
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: false)
            }
            break
        case (.advertErrorOut, .advertRunning, .notReady) : fallthrough
        case (.advertErrorOut, .advertConnecting, .notReady) : fallthrough
        case (.advertErrorOut, .advertSendingData, .notReady) : fallthrough
        case (.browseErrorOut, .browseRunning, .notReady) : fallthrough
        case (.browseErrorOut, .browseInvitationPending, .notReady) : fallthrough
        case (.browseErrorOut, .browseConnecting, .notReady) : fallthrough
        case (.browseErrorOut, .browseReceivingData, .notReady) :
            print("Show \(String(describing: fromState)) Error UI with user info: \(String(describing: userInfo))")
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: false)
                let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                let imageView = UIImageView(image: UIImage(named: "Close"))
                hud.mode = .customView
                hud.customView = imageView
                hud.label.text = "Error"
                hud.hide(animated: true, afterDelay: 2)
            }
            break
            
        default:
            print("WARN: Unknown transition \(String(describing: fromState)) => \(String(describing: toState)) for \(String(describing: event))!")
            break
        }
        
        DispatchQueue.main.async {
            self.updateUI()
        }
    }
}
