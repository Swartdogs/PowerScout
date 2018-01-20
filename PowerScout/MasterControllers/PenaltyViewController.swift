//
//  PenaltyViewController.swift
//  SteamScout
//
//  Created by Dylan Wells on 2/15/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import UIKit

class PenaltyViewController: UIViewController {

    @IBOutlet weak var YellowCard: UIButton!
    @IBOutlet weak var RedCard: UIButton!
    @IBOutlet weak var Foul: UIButton!
    @IBOutlet weak var TechnicalFoul: UIButton!
    @IBAction func YellowCardPressed(_ sender: UIButton) {
        if YellowCard.isSelected {
         YellowCard.isSelected = false
        }
        else {
            YellowCard.isSelected = true
            RedCard.isSelected = false
        }
    }
    @IBAction func RedCardPressed(_ sender: UIButton) {
        if RedCard.isSelected {
            RedCard.isSelected = false
        }
        else {
            RedCard.isSelected = true
            YellowCard.isSelected = false
        }
    }
    @IBAction func FoulPressed(_ sender: UIButton) {
        if Foul.isSelected {
            Foul.isSelected = false
        }
        else {
            Foul.isSelected = true
        }
    }
    @IBAction func TechnicalFoulPressed(_ sender: UIButton) {
        if TechnicalFoul.isSelected {
            TechnicalFoul.isSelected = false
        }
        else {
            TechnicalFoul.isSelected = true
        }
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
