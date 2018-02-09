//
//  ResultsScoringViewController.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/2/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit

class ResultsScoringViewController: UIViewController {
    @IBOutlet weak var autoStartPosLabel: UILabel!
    @IBOutlet weak var autoCrossedLineLabel: UILabel!
    @IBOutlet weak var autoScaleCubesLabel: UILabel!
    @IBOutlet weak var autoSwitchCubesLabel: UILabel!
    
    @IBOutlet weak var teleScaleCubesLabel: UILabel!
    @IBOutlet weak var teleSwitchCubesLabel: UILabel!
    @IBOutlet weak var teleExchangeCubesLabel: UILabel!
    @IBOutlet weak var teleLowCubesLabel: UILabel!
    @IBOutlet weak var teleNormalCubesLabel: UILabel!
    @IBOutlet weak var teleHighCubesLabel: UILabel!
    
    @IBOutlet weak var endgClimbConditionLabel: UILabel!
    
    var match = PowerMatch()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = "Score Results"
        
        if match.finalResult == .noShow {
            autoStartPosLabel.text = "---"
            autoCrossedLineLabel.text = "---"
            autoScaleCubesLabel.text = "---"
            autoSwitchCubesLabel.text = "---"
            
            teleScaleCubesLabel.text = "---"
            teleSwitchCubesLabel.text = "---"
            teleExchangeCubesLabel.text = "---"
            teleLowCubesLabel.text = "---"
            teleNormalCubesLabel.text = "---"
            teleHighCubesLabel.text = "---"
            
            endgClimbConditionLabel.text = "---"
        } else {
            autoStartPosLabel.text = match.autoStartPos.toString()
            autoCrossedLineLabel.text = "\(match.autoCrossedLine ? "Yes" : "No")"
            autoScaleCubesLabel.text = "\(match.autoScaleCubes)"
            autoSwitchCubesLabel.text = "\(match.autoSwitchCubes)"
            
            teleScaleCubesLabel.text = "\(match.teleScaleCubes)"
            teleSwitchCubesLabel.text = "\(match.teleSwitchCubes)"
            teleExchangeCubesLabel.text = "\(match.teleExchangeCubes)"
            teleLowCubesLabel.text = "\(match.teleLow ? "Yes" : "No")"
            teleNormalCubesLabel.text = "\(match.teleNormal ? "Yes" : "No")"
            teleHighCubesLabel.text = "\(match.teleHigh ? "Yes" : "No")"
            
            endgClimbConditionLabel.text = match.endClimbCondition.toString()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
