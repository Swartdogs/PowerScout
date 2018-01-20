//
//  ViewController.swift
//  Team 525 Power Up App
//
//  Created by Matthew Daoud Dylan Wells and Cole Edge on 1/19/18.
//  Copyright © 2018 Team 525 Swartdogs. All rights reserved.
//

import UIKit
import Foundation
import UIKit
import _SwiftUIKitOverlayShims

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var autoScale: UIStepper!
    @IBOutlet weak var autoSwitch: UIStepper!
    @IBOutlet weak var teleScale: UIStepper!
    @IBOutlet weak var teleSwitch: UIStepper!
    @IBOutlet weak var exchangedBlocks: UIStepper!
    @IBOutlet weak var autoAmmountSwitch: UILabel!
    @IBOutlet weak var autoAmmountScale: UILabel!
    @IBOutlet weak var teleAmmountScale: UILabel!
    @IBOutlet weak var teleAmmountSwitch: UILabel!
    @IBOutlet weak var ammountExchangedBlocks: UILabel!
    @IBOutlet weak var autoLine: UISegmentedControl!
    @IBOutlet weak var scaleLow: UISegmentedControl!
    @IBOutlet weak var scaleMedium: UISegmentedControl!
    @IBOutlet weak var scaleHigh: UISegmentedControl!
    @IBOutlet weak var teamNumberInput: UITextField!
    @IBOutlet weak var matchNumberInput: UITextField!
    @IBOutlet weak var startPositionPick: UIPickerView!
    @IBOutlet weak var climbingConditionPick: UIPickerView!
    @IBOutlet weak var positionButton: UIButton!
    @IBOutlet weak var climbButton: UIButton!
    @IBOutlet weak var ClimbYN: UISegmentedControl!
    
    var autoScaleBlock:Int          = 0
    var autoScaleVar = 0
    var autoSwitchVar = 0
    var teleScaleVar = 0
    var teleSwitchVar = 0
    var exchangedBlocksVar = 0
    var autoLineX = false
    var scaleLowX = false
    var scaleMediumX = false
    var scaleHighX = false
    var anyClimb = false
    var startPosition = " "
    var climbingCondition = " "
    
    let startPositions = ["Exchange", "Center", "Non-Exchange"]
    let climbConditions = ["No attempt or failure to climb", "No climb but helped another", "Climb by themselves", "Climb with help", "Climb helping another team"]
    
    override func viewDidLoad() {
        startPositionPick.isHidden = true
        startPositionPick.dataSource = self
        startPositionPick.delegate = self
        climbingConditionPick.isHidden = true
        climbingConditionPick.dataSource = self
        climbingConditionPick.delegate = self
        autoScale.wraps = false
        autoScale.autorepeat = false
        autoScale.maximumValue = 20
        autoScale.stepValue = 1
        autoSwitch.wraps = false
        autoSwitch.autorepeat = false
        autoSwitch.maximumValue = 20
        autoSwitch.stepValue = 1
        teleScale.wraps = false
        teleScale.autorepeat = false
        teleScale.maximumValue = 20
        teleScale.stepValue = 1
        teleSwitch.wraps = false
        teleSwitch.autorepeat = false
        teleSwitch.maximumValue = 20
        teleSwitch.stepValue = 1
        exchangedBlocks.wraps = false
        exchangedBlocks.autorepeat = false
        exchangedBlocks.maximumValue = 20
        exchangedBlocks.stepValue = 1
        super.viewDidLoad()
        // Do any additional setup after loading the view
    }
    
    //UIPickerView stuff (DON'T TOUCH OR SUFFER HELL) I speak from experiance
    @IBAction func climbCondSelect(_ sender: UIButton) {
        if climbingConditionPick.isHidden{
            climbingConditionPick.isHidden = false
        }
    }
    @IBAction func positionSelect(_ sender: UIButton) {
        if startPositionPick.isHidden{
            startPositionPick.isHidden = false
        }
    }
    func numberOfComponents(in pickerview: UIPickerView) -> Int{
       return 1
    }
    
    func pickerView(_ pickerview: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        if pickerview == startPositionPick{
            return startPositions.count
        } else {
            return climbConditions.count
        }
  }
    
    func pickerView(_ pickerview: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerview == startPositionPick{
            return startPositions[row]
        } else {
            return climbConditions[row]
        }
    }
    
    func pickerView(_ pickerview: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerview == startPositionPick{
            positionButton.setTitle(startPositions[row], for: .normal)
            startPositionPick.isHidden = true
            startPosition = startPositions[row]
        }
        if pickerview == climbingConditionPick{
            climbButton.setTitle(climbConditions[row], for: .normal)
            climbingConditionPick.isHidden = true
            climbingCondition = climbConditions[row]
        }
    }
    
    @IBAction func scaleLow(_ sender: UISegmentedControl) {
        if scaleLow.selectedSegmentIndex == 0{
            scaleLowX = false
        }
        if scaleLow.selectedSegmentIndex == 1{
            scaleLowX = true
        }
        
    }
    @IBAction func autoLineCrossed(_ sender: UISegmentedControl) {
        if autoLine.selectedSegmentIndex == 0{
            autoLineX = false
        }
        if autoLine.selectedSegmentIndex == 1{
            autoLineX = true
        }
        
    }
    @IBAction func scaleMedium(_ sender: UISegmentedControl) {
        if scaleMedium.selectedSegmentIndex == 0{
            scaleMediumX = false
        }
        if scaleMedium.selectedSegmentIndex == 1{
            scaleMediumX = true
        }
    }
    @IBAction func scaleHigh(_ sender: UISegmentedControl) {
        if scaleHigh.selectedSegmentIndex == 0{
            scaleHighX = false
        }
        if scaleHigh.selectedSegmentIndex == 1{
            scaleHighX = true
        }
        
    }
   
    @IBAction func climbYN(_ sender: UISegmentedControl) {
        if ClimbYN.selectedSegmentIndex == 0{
             anyClimb = false
        }
        if ClimbYN.selectedSegmentIndex == 1{
             anyClimb = true
        }
    }
   
 
    @IBAction func autoScaleValueChanged(_ sender: UIStepper) {
        autoScaleBlock = Int(sender.value)
        autoAmmountScale.text=Int(sender.value).description
    }
    
    
}

    

    
  








    


   

    
    





