//
//  TeleopViewController.swift
//  SteamScout
//
//  Created by Dylan Wells on 2/13/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import UIKit

class TeleopViewController: UIViewController {
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
            valueLabel.text = Int(sender.value).description
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        stepper.wraps = false
        stepper.autorepeat = false
        stepper.maximumValue = 12
        
        // Do any additional setup after loading the view.
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
