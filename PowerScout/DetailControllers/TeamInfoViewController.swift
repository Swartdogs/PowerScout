//
//  TeamInfoViewController.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 2/7/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit

class TeamInfoViewController: UIViewController {
    
    @IBOutlet weak var teamNumberTextField: UITextField!
    @IBOutlet weak var matchNumberTextField: UITextField!
    @IBOutlet var allianceButtons: [UIButton]!
    @IBOutlet weak var noShowButton: UIButton!
    
    var m:Match = PowerMatch()
    var matchStore:MatchStore!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(TeamInfoViewController.backgroundTap(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        m = matchStore.currentMatch ?? m
        
        m.isCompleted |= 1;
        teamNumberTextField.text = m.teamNumber > 0 ? "\(m.teamNumber)" : ""
        matchNumberTextField.text = m.matchNumber > 0 ? "\(m.matchNumber)" : ""
        for b in allianceButtons {
            b.isSelected = b.tag == m.alliance.rawValue
        }
        noShowButton.isSelected = m.finalResult == .noShow
        
        readyToMoveOn()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        teamNumberTextField.resignFirstResponder()
        matchNumberTextField.resignFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AppUtility.unlockOrientation()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueCancelStartMatch" {
            matchStore.cancelCurrentMatchEdit()
        } else if segue.identifier == "segueToEndMatchNoShow" {
            matchStore.updateCurrentMatchForType(.teamInfo, match: m)
            matchStore.finishCurrentMatch()
        } else if segue.identifier == "segueToDataEntry" {
            AppUtility.lockOrientation(to: .portrait)
            matchStore.updateCurrentMatchForType(.teamInfo, match: m)
            if let destNC = segue.destination as? UINavigationController {
                if let destVC = destNC.topViewController as? DataEntryViewController {
                    destVC.matchStore = matchStore
                }
            }
        }
    }
    
    func readyToMoveOn() {
        let disable = m.teamNumber <= 0 || m.matchNumber <= 0 || m.alliance == .unknown
        self.navigationItem.rightBarButtonItem?.isEnabled = !disable
    }
    
    @IBAction func textFieldEditDidEnd(_ sender: UITextField) {
        if sender.text!.count <= 0 { return }
        if sender === teamNumberTextField {
            m.teamNumber = (Int(sender.text!) ?? m.teamNumber)!
            sender.text = m.teamNumber > 0 ? "\(m.teamNumber)" : ""
        } else if sender === matchNumberTextField {
            m.matchNumber = (Int(sender.text!) ?? m.matchNumber)!
            sender.text = m.matchNumber > 0 ? "\(m.matchNumber)" : ""
        }
        
        readyToMoveOn()
    }
    
    @IBAction func allianceTap(_ sender: UIButton) {
        m.alliance = AllianceType(rawValue: sender.tag)!
        
        for b in allianceButtons {
            b.isSelected = b.tag == sender.tag
        }
        self.view.endEditing(true)
        readyToMoveOn()
    }
    
    @IBAction func noShowTap(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if(sender.isSelected) {
            m.finalResult = .noShow
            self.navigationItem.rightBarButtonItem?.title = "End Match"
        } else {
            m.finalResult = .none
            self.navigationItem.rightBarButtonItem?.title = "Next"
        }
        self.view.endEditing(true)
    }
    
    @IBAction func nextButtonTap(_ sender:UIBarButtonItem) {
        if m.finalResult == .noShow {
            let noShowAC = UIAlertController(title: "No Show Match", message: "You've indicated that this team is a no show.  The match will now end.  Are you sure you want to continue?", preferredStyle: .alert)
            let continueAction = UIAlertAction(title: "Continue", style: .default, handler: { (action) in
                self.performSegue(withIdentifier: "segueToEndMatchNoShow", sender: nil)
            })
            noShowAC.addAction(continueAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            noShowAC.addAction(cancelAction)
            
            self.present(noShowAC, animated: true, completion: nil)
        } else {
            self.performSegue(withIdentifier: "segueToDataEntry", sender: nil)
        }
    }
    
    @objc func backgroundTap(_ sender:UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}
