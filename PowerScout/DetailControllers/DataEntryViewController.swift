//
//  ViewController.swift
//  Team 525 Power Up App
//
//  Created by Matthew Daoud Dylan Wells and Cole Edge on 1/19/18.
//  Copyright © 2018 Team 525 Swartdogs. All rights reserved.
//

import UIKit
import Foundation

class DataEntryViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var autoScale: UIStepper!
    @IBOutlet weak var autoSwitch: UIStepper!
    @IBOutlet weak var teleScale: UIStepper!
    @IBOutlet weak var teleSwitch: UIStepper!
    @IBOutlet weak var exchangedBlocks: UIStepper!
    @IBOutlet weak var autoSwitchMiss: UIStepper!
    @IBOutlet weak var autoScaleMiss: UIStepper!
    @IBOutlet weak var teleScaleMiss: UIStepper!
    @IBOutlet weak var teleSwitchMiss: UIStepper!
    @IBOutlet weak var teleAmmountSwitchMiss: UILabel!
    @IBOutlet weak var teleAmmountScaleMiss: UILabel!
    @IBOutlet weak var autoAmmountSwitch: UILabel!
    @IBOutlet weak var autoAmmountScale: UILabel!
    @IBOutlet weak var autoAmmountScaleMiss: UILabel!
    @IBOutlet weak var autoAmmountSwitchMiss: UILabel!
    @IBOutlet weak var teleAmmountScale: UILabel!
    @IBOutlet weak var teleAmmountSwitch: UILabel!
    @IBOutlet weak var ammountExchangedBlocks: UILabel!
    @IBOutlet weak var autoLine: UISegmentedControl!
    @IBOutlet weak var autoField: UISegmentedControl!
//    @IBOutlet weak var scaleLow: UISegmentedControl!
//    @IBOutlet weak var scaleMedium: UISegmentedControl!
//    @IBOutlet weak var scaleHigh: UISegmentedControl!
    @IBOutlet weak var positionTextField: UITextField!
    @IBOutlet weak var climbTextField:UITextField!
    @IBOutlet weak var TipYN: UISegmentedControl!
    @IBOutlet weak var StalledYN: UISegmentedControl!
    @IBOutlet weak var TechFYN: UISegmentedControl!
    @IBOutlet weak var DefenseYN: UISegmentedControl!
    @IBOutlet weak var PartnerYN: UISegmentedControl!
    
    var startPositionPick: UIPickerView!
    var climbingConditionPick:UIPickerView!
    
    var match:PowerMatch = PowerMatch()
    var matchStore:MatchStore!
    
    var startPositionDone = false
    var climbPositionDone = false
    var readyToMove = false
    
    override var disablesAutomaticKeyboardDismissal: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startPositionPick = UIPickerView()
        climbingConditionPick = UIPickerView()
        
        startPositionPick.dataSource = self
        startPositionPick.delegate = self
        climbingConditionPick.dataSource = self
        climbingConditionPick.delegate = self
        autoScale.wraps = false
        autoScale.autorepeat = false
        autoScale.maximumValue = 20
        autoScale.stepValue = 1
        autoScaleMiss.wraps = false
        autoScaleMiss.autorepeat = false
        autoScaleMiss.maximumValue = 20
        autoScaleMiss.stepValue = 1
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
        
        positionTextField.inputView = startPositionPick
        positionTextField.delegate = self
        climbTextField.inputView = climbingConditionPick
        climbTextField.delegate = self
        
        let positionToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        positionToolbar.barStyle = UIBarStyle.default
        positionToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(DataEntryViewController.handlePickerDoneButton(_:)))
        ]
        positionToolbar.sizeToFit()
        positionTextField.inputAccessoryView = positionToolbar
        
        let climbToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        climbToolbar.barStyle = UIBarStyle.default
        climbToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(DataEntryViewController.handlePickerDoneButton(_:)))
        ]
        climbToolbar.sizeToFit()
        climbTextField.inputAccessoryView = climbToolbar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        startPositionDone = false
        climbPositionDone = false
        readyToMove = false
        
        readyToMoveOn()
        
        match = matchStore.currentMatch as? PowerMatch ?? match
        
        self.navigationItem.title = "Match: \(match.matchNumber) Team: \(match.teamNumber)"
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
    
    func readyToMoveOn() {
        readyToMove = startPositionDone && climbPositionDone
    }
    
    @IBAction func handleDoneButton(_ sender:UIBarButtonItem) {
        if !readyToMove {
            let alertController = UIAlertController(title: "Unable to Complete Match", message: "You must complete the Start Position and End Climb Condition Fields to complete the match!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            self.performSegue(withIdentifier: "unwindToMatchView", sender: self)
        }
    }
    
    @IBAction func unwindToDataEntry(_ sender:UIStoryboardSegue) {
        
    }
    
    @objc func handlePickerDoneButton(_ sender: UIBarButtonItem) {
        self.positionTextField.resignFirstResponder()
        self.climbTextField.resignFirstResponder()
    }
    
    // MARK: UIPickerView Functions
    // UIPickerView stuff (DON'T TOUCH OR SUFFER HELL) I speak from experiance
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
            positionTextField.text = PowerStartPositionType.all[row].toString()
            match.autoStartPos = PowerStartPositionType(rawValue: row+1)!
            startPositionDone = true
            self.positionTextField.resignFirstResponder()
        }
        if pickerview == climbingConditionPick{
            climbTextField.text = PowerEndClimbPositionType.all[row].toString()
            match.endClimbCondition = PowerEndClimbPositionType(rawValue: row)!
            climbPositionDone = true
            self.climbTextField.resignFirstResponder()
        }
        
        readyToMoveOn()
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
    @IBAction func segmentedControlSelect(_ sender: UISegmentedControl) {
        switch sender {
        case autoLine:
            match.autoCrossedLine = sender.selectedSegmentIndex == 1
            break
        case autoField:
            match.autoCrossedField = sender.selectedSegmentIndex == 1
            break
            
            // These were removed, so they can't be referenced in code anymore (should probably delete these lines)
//        case scaleLow:
//            match.teleLow = sender.selectedSegmentIndex == 1
//            break
//        case scaleMedium:
//            match.teleNormal = sender.selectedSegmentIndex == 1
//            break
//        case scaleHigh:
//            match.teleHigh = sender.selectedSegmentIndex == 1
//            break
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
        case DefenseYN:
            match.endPlayedDefense = sender.selectedSegmentIndex == 1
            break
        case PartnerYN:
            match.endConsiderPartner = sender.selectedSegmentIndex == 1
            break
        default:
            break
        }
        
        readyToMoveOn()
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
        case autoScaleMiss:
            match.autoScaleMissedCubes = Int(sender.value)
            autoAmmountScaleMiss.text = match.autoScaleMissedCubes.description
            break
        case autoSwitchMiss:
            match.autoSwitchMissedCubes = Int(sender.value)
            autoAmmountSwitchMiss.text = match.autoSwitchMissedCubes.description
            break
        case teleScaleMiss:
            match.teleScaleMissedCubes = Int(sender.value)
            teleAmmountScaleMiss.text = match.teleScaleMissedCubes.description
            break
        case teleSwitchMiss:
            match.teleSwitchMissedCubes = Int(sender.value)
            teleAmmountSwitchMiss.text = match.teleSwitchMissedCubes.description
            break
        default:
            break
        }
        
        readyToMoveOn()
    }
}
