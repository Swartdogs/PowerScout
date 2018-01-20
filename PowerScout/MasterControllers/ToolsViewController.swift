//
//  ToolsViewController.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 3/7/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit
import MBProgressHUD

class ToolsViewController: UIViewController {
    
    @IBOutlet weak var fieldLayout:UIImageView!
    @IBOutlet weak var getScheduleButton:UIButton!
    @IBOutlet weak var buildListButton:UIButton!
    
    @IBOutlet var listSelectorButtons:[UIButton]!
    
    fileprivate var selectedList = 0

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setToolbarHidden(true, animated: false)
        
        //fieldLayout.image = MatchStore.sharedStore.fieldLayout.getImage()
        self.view.backgroundColor = themeGray
        
        getScheduleButton.isEnabled = EventStore.sharedStore.selectedEvent != nil
        buildListButton.isEnabled = false
        selectedList = 0
        for b in listSelectorButtons {
            b.isSelected = false
            b.isEnabled = ScheduleStore.sharedStore.currentSchedule != nil
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func getEventList(_ sender:UIButton) {
        let hud = MBProgressHUD.showAdded(to: self.navigationController!.view, animated: true)
        hud.label.text = "Loading..."
        hud.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelRequest(_:))))
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        EventStore.sharedStore.getEventsList({(progress) in
            DispatchQueue.main.async(execute: {
                let hud = MBProgressHUD(for: self.navigationController!.view)
                hud?.mode = .determinate
                hud?.progress = Float(progress)
            })
        }, completion: {(error) in
            DispatchQueue.main.async(execute: {
                let hud = MBProgressHUD(for: self.navigationController!.view)
                let image = UIImage(named: error == nil ? "Checkmark" : "Close")
                let imageView = UIImageView(image: image)
                self.navigationItem.leftBarButtonItem?.isEnabled = true
                hud?.customView = imageView
                hud?.mode = .customView
                hud?.label.text = error == nil ? "Completed" : "Error"
                hud?.hide(animated: true, afterDelay: 1)
            })
        })
    }
    
    @objc func cancelRequest(_ sender:UITapGestureRecognizer) {
        EventStore.sharedStore.cancelRequest({
            DispatchQueue.main.async(execute: {
                let hud = MBProgressHUD(for: self.navigationController!.view)
                let imageView = UIImageView(image: UIImage(named: "Close"))
                self.navigationItem.leftBarButtonItem?.isEnabled = true
                hud?.customView = imageView
                hud?.mode = .customView
                hud?.label.text = "Canceled"
                hud?.hide(animated: true, afterDelay: 1)
            })
        })
    }
    
    @IBAction func selectList(_ sender:UIButton) {
        selectedList = sender.isSelected ? 0 : sender.tag
        for b in listSelectorButtons {
            b.isSelected = b.tag == selectedList
        }
        buildListButton.isEnabled = selectedList > 0
    }
    
    @IBAction func getSchedule(_ sender:UIButton) {
        ScheduleStore.sharedStore.currentSchedule = EventStore.sharedStore.selectedEvent?.code
        let hud = MBProgressHUD.showAdded(to: self.navigationController!.view, animated: true)
        hud.mode = .indeterminate
        hud.label.text = "Loading..."
        hud.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ToolsViewController.cancelScheduleRequest(_:))))
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        self.getScheduleButton.isEnabled = false
        self.buildListButton.isEnabled = false
        ScheduleStore.sharedStore.getScheduleList({ (progress:Double) in
            DispatchQueue.main.async(execute: {
                let hud = MBProgressHUD(for: self.navigationController!.view)
                hud?.mode = .determinate
                hud?.progress = Float(progress)
            })
            }, completion: { (error) in
                DispatchQueue.main.async(execute: {
                    let hud = MBProgressHUD(for: self.navigationController!.view)
                    let imageView = UIImageView(image: UIImage(named: error == nil ? "Checkmark" : "Close"))
                    self.navigationItem.leftBarButtonItem?.isEnabled = true
                    self.getScheduleButton.isEnabled = true
                    for b in self.listSelectorButtons {
                        b.isEnabled = ScheduleStore.sharedStore.currentSchedule != nil
                    }
                    self.buildListButton.isEnabled = self.selectedList > 0
                    hud?.customView = imageView
                    hud?.mode = .customView
                    hud?.label.text = error == nil ? "Completed" : "Error"
                    hud?.hide(animated: true, afterDelay: 1)
                })
        })
    }
    
    @IBAction func buildList(_ sender:UIButton) {
        if ScheduleStore.sharedStore.currentSchedule != EventStore.sharedStore.selectedEvent?.code {
            let scheduleAC = UIAlertController(title: "Current Schedule is different from Selected Event", message: "You have a schedule from a different event! Would you like to continue with the build, or get the new schedule", preferredStyle: .alert)
            let buildAction = UIAlertAction(title: "Continue With Build", style: .default, handler: { (action) in
                self.confirmBuildList()
            })
            scheduleAC.addAction(buildAction)
            
            let getScheduleAction = UIAlertAction(title: "Get New Schedule", style: .default, handler: { (action) in
                self.getSchedule(self.getScheduleButton)
            })
            scheduleAC.addAction(getScheduleAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            scheduleAC.addAction(cancelAction)
            
            self.present(scheduleAC, animated: true, completion: nil)
        } else {
            confirmBuildList()
        }
    }
    
    func confirmBuildList() {
        var list = (selectedList & 4) == 4 ? "Blue" : "Red"
        list += " \(selectedList & 3)"
        let ac = UIAlertController(title: "Build \(list) List for event \(ScheduleStore.sharedStore.currentSchedule!)", message: "Building this list will clear the previous queue of matches.  Do you want to continue?", preferredStyle: .alert)
        let continueAction = UIAlertAction(title: "Continue", style: .destructive, handler: {(action) in
            let hud = MBProgressHUD.showAdded(to: self.navigationController!.view, animated: true)
            hud.mode = .indeterminate
            hud.label.text = "Building List"
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: {
                ScheduleStore.sharedStore.buildMatchListForGroup(self.selectedList)
                DispatchQueue.main.async(execute: {
                    let hud = MBProgressHUD(for: self.navigationController!.view)
                    let imageView = UIImageView(image: UIImage(named: "Checkmark"))
                    hud?.customView = imageView
                    hud?.mode = .customView
                    hud?.label.text = "Completed"
                    hud?.hide(animated: true, afterDelay: 1)
                })
            })
        })
        ac.addAction(continueAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(cancelAction)
        
        self.present(ac, animated: true, completion: nil)
    }
    
    @objc func cancelScheduleRequest(_ sender:UITapGestureRecognizer) {
        ScheduleStore.sharedStore.cancelRequest({
            DispatchQueue.main.async(execute: {
                let hud = MBProgressHUD(for: self.navigationController!.view)
                let imageView = UIImageView(image: UIImage(named: "Close"))
                self.navigationItem.leftBarButtonItem?.isEnabled = true
                self.getScheduleButton.isEnabled = true
                for b in self.listSelectorButtons {
                    b.isEnabled = ScheduleStore.sharedStore.currentSchedule != nil
                }
                self.buildListButton.isEnabled = self.selectedList > 0
                hud?.customView = imageView
                hud?.mode = .customView
                hud?.label.text = "Canceled"
                hud?.hide(animated: true, afterDelay: 1)
            })
        })
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segueToEventSelection" {
            let nav = segue.destination as! UINavigationController
            // TODO: REMOVE THIS -- Events are not going to be used
//            let estvc = nav.topViewController as! EventSelectionTableViewController
//            estvc.delegate = self
        }
    }
}
