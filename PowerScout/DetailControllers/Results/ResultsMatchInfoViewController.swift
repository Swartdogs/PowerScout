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
        
        
        }
    }


    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


