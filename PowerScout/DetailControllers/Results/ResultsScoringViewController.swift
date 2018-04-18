//
//  ResultsScoringViewController.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/2/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit

class ResultsScoringViewController: UIViewController {
    @IBOutlet weak var infoTeamNumber: UILabel!
    @IBOutlet weak var infoMatchNumber: UILabel!
    @IBOutlet weak var infoAlliance: UILabel!
    
    @IBOutlet weak var autoStartPosLabel: UILabel!
    @IBOutlet weak var autoCrossedLineLabel: UILabel!
    @IBOutlet weak var autoScaleCubesLabel: UILabel!
    @IBOutlet weak var autoScaleCubesMissedLabel: UILabel!
    @IBOutlet weak var autoSwitchCubesLabel: UILabel!
    @IBOutlet weak var autoSwitchCubesMissedLabel: UILabel!
    @IBOutlet weak var autoCrossedField: UILabel!
    
    @IBOutlet weak var teleScaleCubesLabel: UILabel!
    @IBOutlet weak var teleScaleCubesMissedLabel: UILabel!
    @IBOutlet weak var teleSwitchCubesLabel: UILabel!
    @IBOutlet weak var teleSwitchCubesMissedLabel: UILabel!
    @IBOutlet weak var teleExchangeCubesLabel: UILabel!
//    @IBOutlet weak var teleLowCubesLabel: UILabel!
//    @IBOutlet weak var teleNormalCubesLabel: UILabel!
//    @IBOutlet weak var teleHighCubesLabel: UILabel!
    
    @IBOutlet weak var endgClimbConditionLabel: UILabel!
    @IBOutlet weak var endgRobotState: UILabel!
    @IBOutlet weak var endgReceivedTechFoul: UILabel!
    @IBOutlet weak var endgPlayedDefense: UILabel!
    @IBOutlet weak var endgConsiderPartner: UILabel!
    
    var match = PowerMatch()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        infoTeamNumber.text = "\(match.teamNumber)"
        infoMatchNumber.text = "\(match.matchNumber)"
        infoAlliance.text = match.alliance.toString()
        
        if match.finalResult == .noShow {
            autoStartPosLabel.text = "---"
            autoCrossedLineLabel.text = "---"
            autoCrossedField.text = "---"
            autoScaleCubesLabel.text = "---"
            autoScaleCubesMissedLabel.text = "---"
            autoSwitchCubesLabel.text = "---"
            autoSwitchCubesMissedLabel.text = "---"
            
            teleScaleCubesLabel.text = "---"
            teleScaleCubesMissedLabel.text = "---"
            teleSwitchCubesLabel.text = "---"
            teleSwitchCubesMissedLabel.text = "---"
            teleExchangeCubesLabel.text = "---"
//            teleLowCubesLabel.text = "---"
//            teleNormalCubesLabel.text = "---"
//            teleHighCubesLabel.text = "---"
            
            endgClimbConditionLabel.text = "---"
            endgReceivedTechFoul.text = "---"
            endgRobotState.text = "---"
            endgPlayedDefense.text = "---"
            endgConsiderPartner.text = "---"
        } else {
            autoStartPosLabel.text = match.autoStartPos.toString()
            autoCrossedLineLabel.text = "\(match.autoCrossedLine ? "Yes" : "No")"
            autoCrossedField.text = match.autoCrossedField ? "Yes" : "No"
            autoScaleCubesLabel.text = "\(match.autoScaleCubes)"
            autoScaleCubesMissedLabel.text = "\(match.autoScaleMissedCubes)"
            autoSwitchCubesLabel.text = "\(match.autoSwitchCubes)"
            autoSwitchCubesMissedLabel.text = "\(match.autoSwitchMissedCubes)"
            
            teleScaleCubesLabel.text = "\(match.teleScaleCubes)"
            teleScaleCubesMissedLabel.text = "\(match.teleScaleMissedCubes)"
            teleSwitchCubesLabel.text = "\(match.teleSwitchCubes)"
            teleSwitchCubesMissedLabel.text = "\(match.teleSwitchMissedCubes)"
            teleExchangeCubesLabel.text = "\(match.teleExchangeCubes)"
//            teleLowCubesLabel.text = "\(match.teleLow ? "Yes" : "No")"
//            teleNormalCubesLabel.text = "\(match.teleNormal ? "Yes" : "No")"
//            teleHighCubesLabel.text = "\(match.teleHigh ? "Yes" : "No")"
            
            endgClimbConditionLabel.text = match.endClimbCondition.toString()
            endgReceivedTechFoul.text = (match.finalTechFouls == 1) ? "Yes" : "No"
            endgRobotState.text = match.finalRobot.toString()
            endgPlayedDefense.text = match.endPlayedDefense ? "Yes" : "No"
            endgConsiderPartner.text = match.endConsiderPartner ? "Yes" : "No"
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
