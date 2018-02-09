//
//  ResultsMatchInfoViewController.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/2/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit

class ResultsMatchInfoViewController: UIViewController {

    @IBOutlet weak var teamNumber: UILabel!
    @IBOutlet weak var matchNumber: UILabel!
    @IBOutlet weak var alliance: UILabel!
    @IBOutlet weak var finalResult: UILabel!
    @IBOutlet weak var finalScore: UILabel!
    @IBOutlet weak var finalRobot: UILabel!
    @IBOutlet weak var finalFouls: UILabel!
    @IBOutlet weak var finalTechFouls: UILabel!
    @IBOutlet weak var finalYellowCards: UILabel!
    @IBOutlet weak var finalRedCards: UILabel!
    @IBOutlet weak var finalComments: UILabel!
    
    var match = PowerMatch()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationItem.title = "Match Info"
        
        teamNumber.text = "\(match.teamNumber)"
        matchNumber.text = "\(match.matchNumber)"
        alliance.text = "\(match.alliance.toString())"
        
        if match.finalResult == .noShow {
            finalResult.text = "No Show"
            finalScore.text = "---"
            finalRobot.text = "---"
            finalFouls.text = "---"
            finalTechFouls.text = "---"
            finalYellowCards.text = "---"
            finalRedCards.text = "---"
            finalComments.text = ""
        } else {
            finalResult.text = "\(match.finalResult.toString()) (\(match.finalRankingPoints))"
            finalScore.text = "\(match.finalScore) (\(match.finalPenaltyScore))"
            finalRobot.text = "\(match.finalRobot.toString())"
            finalFouls.text = "\(match.finalFouls)"
            finalTechFouls.text = "\(match.finalTechFouls)"
            finalYellowCards.text = "\(match.finalYellowCards)"
            finalRedCards.text = "\(match.finalRedCards)"
            finalComments.text = match.finalComments
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
