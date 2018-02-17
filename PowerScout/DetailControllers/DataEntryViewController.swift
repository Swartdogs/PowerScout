//
//  ViewController.swift
//  Team 525 Power Up App
//
//  Created by Matthew Daoud Dylan Wells and Cole Edge on 1/19/18.
//  Copyright © 2018 Team 525 Swartdogs. All rights reserved.
//

import UIKit
import Foundation

class DataEntryViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
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
    @IBOutlet weak var startPositionPick: UIPickerView!
    @IBOutlet weak var climbingConditionPick: UIPickerView!
    @IBOutlet weak var positionButton: UIButton!
    @IBOutlet weak var climbButton: UIButton!
    @IBOutlet weak var TipYN: UISegmentedControl!
    @IBOutlet weak var StalledYN: UISegmentedControl!
    @IBOutlet weak var TechFYN: UISegmentedControl!
    
    var match:PowerMatch = PowerMatch()
    var matchStore:MatchStore!
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        match = matchStore.currentMatch as? PowerMatch ?? match
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            if id.elementsEqual("unwindCancelMatch") {
                matchStore.cancelCurrentMatchEdit()
            } else if id.elementsEqual("segueToFinalInfo") {
                if let destNC = segue.destination as? UINavigationController {
                    if let destVC = destNC.topViewController as? FinalViewController {
                        destVC.matchStore = matchStore
                    }
                }
            } else if id.elementsEqual("unwindToMatchView") {
                matchStore.updateCurrentMatchForType(.finalStats, match: match)
                matchStore.finishCurrentMatch()
            }
        }
    }
    
    @IBAction func unwindToDataEntry(_ sender:UIStoryboardSegue) {
        
    }
    
    // MARK: UIPickerView Functions
    // UIPickerView stuff (DON'T TOUCH OR SUFFER HELL) I speak from experiance
    @IBAction func climbCondSelect(_ sender: UIButton) {
        if climbingConditionPick.isHidden {
            climbingConditionPick.isHidden = false
        }
    }
    @IBAction func positionSelect(_ sender: UIButton) {
        if startPositionPick.isHidden {
            startPositionPick.isHidden = false
        }
    }
    
    func numberOfComponents(in pickerview: UIPickerView) -> Int{
       return 1
    }
    
    func pickerView(_ pickerview: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        if pickerview == startPositionPick {
            return PowerStartPositionType.all.count
        } else {
            return PowerEndClimbPositionType.all.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attrs = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 22)]
        if pickerView == startPositionPick {
            return NSAttributedString(string: PowerStartPositionType.all[row].toString(), attributes: attrs)
        } else {
            return NSAttributedString(string: PowerEndClimbPositionType.all[row].toString(), attributes: attrs)
        }
    }
    
    func pickerView(_ pickerview: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerview == startPositionPick{
            positionButton.setTitle(PowerStartPositionType.all[row].toString(), for: .normal)
            startPositionPick.isHidden = true
            match.autoStartPos = PowerStartPositionType(rawValue: row+1)!
        }
        if pickerview == climbingConditionPick{
            climbButton.setTitle(PowerEndClimbPositionType.all[row].toString(), for: .normal)
            climbingConditionPick.isHidden = true
            match.endClimbCondition = PowerEndClimbPositionType(rawValue: row)!
        }
    }
    
    @IBAction func segmentedControlSelect(_ sender: UISegmentedControl) {
        switch sender {
        case autoLine:
            match.autoCrossedLine = sender.selectedSegmentIndex == 1
            break
        case scaleLow:
            match.teleLow = sender.selectedSegmentIndex == 1
            break
        case scaleMedium:
            match.teleNormal = sender.selectedSegmentIndex == 1
            break
        case scaleHigh:
            match.teleHigh = sender.selectedSegmentIndex == 1
            break
        case TipYN:
            if sender.selectedSegmentIndex == 1 {
                match.finalRobot.formUnion(.Tipped)
            } else {
                match.finalRobot.subtract(.Tipped)
            }
            break
        case StalledYN:
            if sender.selectedSegmentIndex == 1 {
                match.finalRobot.formUnion(.Stalled)
            } else {
                match.finalRobot.subtract(.Stalled)
            }
            break
        case TechFYN:
            if sender.selectedSegmentIndex == 1 {
                match.finalTechFouls = 1
            } else {
                match.finalTechFouls = 0
            }
        default:
            break
        }
    }
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        switch sender {
        case autoScale:
            match.autoScaleCubes = Int(sender.value)
            autoAmmountScale.text = match.autoScaleCubes.description
            break
        case autoSwitch:
            match.autoSwitchCubes = Int(sender.value)
            autoAmmountSwitch.text = match.autoSwitchCubes.description
            break
        case teleScale:
            match.teleScaleCubes = Int(sender.value)
            teleAmmountScale.text = match.teleScaleCubes.description
            break
        case teleSwitch:
            match.teleSwitchCubes = Int(sender.value)
            teleAmmountSwitch.text = match.teleSwitchCubes.description
            break
        case exchangedBlocks:
            match.teleExchangeCubes = Int(sender.value)
            ammountExchangedBlocks.text = match.teleExchangeCubes.description
            break
        default:
            break
        }
    }
}
