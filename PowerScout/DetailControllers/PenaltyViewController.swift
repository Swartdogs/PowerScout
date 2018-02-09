//
//  PenaltyViewController.swift
//  SteamScout
//
//  Created by Dylan Wells on 2/15/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import UIKit

protocol PenaltyViewControllerDelegate: AnyObject  {
    func penaltyViewController(_ penaltyVC:PenaltyViewController, didAddPenalty penalty:PenaltyType)
    func penaltyViewController(_ penaltyVC:PenaltyViewController, didRemovePenalty penalty:PenaltyType)
    func penaltyViewControllerDidCommitPenalties(_ penaltyVC:PenaltyViewController)
}

class PenaltyViewController: UIViewController {

    @IBOutlet weak var YellowCard: UIButton!
    @IBOutlet weak var RedCard: UIButton!
    @IBOutlet weak var Foul: UIButton!
    @IBOutlet weak var TechnicalFoul: UIButton!
    
    weak var delegate:PenaltyViewControllerDelegate?
    
    @IBAction func handleButtonPress(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        switch sender {
        case YellowCard:
            if YellowCard.isSelected {
                RedCard.isSelected = false
                delegate?.penaltyViewController(self, didAddPenalty: .yellowCard)
                delegate?.penaltyViewController(self, didRemovePenalty: .redCard)
            } else {
                delegate?.penaltyViewController(self, didRemovePenalty: .yellowCard)
            }
            break
        case RedCard:
            if RedCard.isSelected {
                YellowCard.isSelected = false
                delegate?.penaltyViewController(self, didAddPenalty: .redCard)
                delegate?.penaltyViewController(self, didRemovePenalty: .yellowCard)
            } else {
                delegate?.penaltyViewController(self, didRemovePenalty: .redCard)
            }
            break
        case Foul:
            if Foul.isSelected {
                delegate?.penaltyViewController(self, didAddPenalty: .foul)
            } else {
                delegate?.penaltyViewController(self, didRemovePenalty: .foul)
            }
            break
        case TechnicalFoul:
            if TechnicalFoul.isSelected {
                delegate?.penaltyViewController(self, didAddPenalty: .techFoul)
            } else {
                delegate?.penaltyViewController(self, didRemovePenalty: .techFoul)
            }
            break
        default:
            break
        }
    }
    
    @IBAction func handleSave(_ sender:UIBarButtonItem) {
        delegate?.penaltyViewControllerDidCommitPenalties(self)
        
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        YellowCard.isSelected = false
        RedCard.isSelected = false
        Foul.isSelected = false
        TechnicalFoul.isSelected = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
