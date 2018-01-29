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

protocol DataTransferViewControllerDelegate: class {
    func dataTransferViewController(_ dataTransferViewController: DataTransferViewController, foundNearbyDevice nearbyDevice: NearbyDevice)
    func dataTransferViewController(_ dataTransferViewController: DataTransferViewController, lostNearbyDevice nearbyDevice: NearbyDevice)
}

class DataTransferViewController: UIViewController, ServiceStoreDelegate {
    
    @IBOutlet var advertProceed: UIButton!
    @IBOutlet var advertGoBack: UIButton!
    @IBOutlet var browseProceed: UIButton!
    @IBOutlet var browseGoBack: UIButton!
    @IBOutlet var reset: UIButton!
    
    weak var delegate:DataTransferViewControllerDelegate?
    var selectedDevice: NearbyDevice?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ServiceStore.shared.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        ServiceStore.shared.delegate = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handleButtonSelect(_ sender: UIButton) {
        switch sender {
        case advertProceed:
            ServiceStore.shared.proceedWithAdvertising()
            break
        case advertGoBack:
            ServiceStore.shared.goBackWithAdvertising()
            break
        case browseProceed:
            ServiceStore.shared.proceedWithBrowsing()
            break
        case browseGoBack:
            ServiceStore.shared.goBackWithBrowsing()
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
    
    // MARK: - ServiceStoreDelegate
    
    func serviceStore(_ serviceStore: ServiceStore, withSession session: MCSession, didChangeState state: MCSessionState) {
        print("ServiceStore Session: \(session.debugDescription) did change state: \(state)")
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
            ServiceStore.shared.sendMessage("ping")
            ServiceStore.shared.sendMessage("EOD")
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
        case (.advertProceed, .advertSendingData, .notReady) : fallthrough
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
    }
}
