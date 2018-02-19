//
//  MasterViewController.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 1/30/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit
import MBProgressHUD

class MasterViewController: UITableViewController {
    
    @IBOutlet var clearExportButton:UIBarButtonItem!
    
    var matchStore:MatchStore!
    var selectedMatch:Match?
    var serviceStore:ServiceStore!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            serviceStore = appDelegate.serviceStore
        } else {
            serviceStore = ServiceStore(withMatchStore: matchStore)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        
        AppUtility.unlockOrientation()
        self.navigationController?.setToolbarHidden(false, animated: false)
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMatchSummary" || segue.identifier == "segueToRecentMatchResults" {
            var match = self.matchStore.allMatches.last ?? MatchImpl()
            if segue.identifier == "showMatchSummary", let indexPath = self.tableView.indexPathForSelectedRow {
                match = self.matchStore.allMatches[indexPath.row]
            }
            if let nav = segue.destination as? UINavigationController,
                let sr = nav.topViewController as? ResultsScoringViewController {
                sr.match = match as! PowerMatch
                sr.navigationItem.title = "Match: \(match.matchNumber) Team: \(match.teamNumber)"
                sr.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                sr.navigationItem.leftItemsSupplementBackButton = true
            }
        } else if segue.identifier == "SegueToNewMatch" {
            self.matchStore.createMatch(PowerMatch.self, onComplete:nil)
            if let destNC = segue.destination as? UINavigationController {
                if let destVC = destNC.topViewController as? TeamInfoViewController {
                    destVC.matchStore = matchStore
                }
            }
            segue.destination.popoverPresentationController!.delegate = self
        } else if segue.identifier == "SegueToTransfer" {
            if let vc = segue.destination as? DataTransferViewController {
                vc.matchStore = matchStore
                vc.serviceStore = serviceStore
                serviceStore.resetStateMachine()
                serviceStore.delegate = vc
                
                vc.transferMode = .doNothing
            }
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        clearExportButton.title = self.isEditing ? "Clear" : "Export";
    }
    
    // MARK: Unwind Segues
    
    @IBAction func unwindToMatchView(_ sender:UIStoryboardSegue) {
        AppUtility.revertOrientation()
        self.tableView.reloadData()
    }
    
    @IBAction func unwindToCompletedMatchView(_ sender:UIStoryboardSegue) {
        AppUtility.revertOrientation()
        self.tableView.reloadData()
        self.performSegue(withIdentifier: "segueToRecentMatchResults", sender: self)
    }

    @IBAction func handleExportOrClear(_ sender:UIBarButtonItem) {
        if self.isEditing {
            handleClear(sender)
        } else {
            handleExport(sender)
        }
    }
    
    func handleClear(_ sender:UIBarButtonItem) {
        let ac = UIAlertController(title: "Clear Matches", message: "", preferredStyle: .actionSheet)

        let clearAllMatches = UIAlertAction(title: "Clear All Matches", style: .destructive, handler: {(action) in
            self.clearMatchData(3)
        })

        ac.addAction(clearAllMatches)
        
        ac.popoverPresentationController?.barButtonItem = sender
        ac.popoverPresentationController?.sourceView = self.view
        
        ac.view.layoutIfNeeded()
        self.present(ac, animated: true, completion: nil)
    }
    
    func clearMatchData(_ type:Int) {
        let clearAllMatches = "Are you sure you want to clear all Match Data? Doing so will also permanently delete match data when data is exported next!"
        let ac = UIAlertController(title: "Clear Data", message: clearAllMatches, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let continueAction = UIAlertAction(title: "Continue", style: .destructive, handler: {(action) in
            let hud = MBProgressHUD.showAdded(to: self.navigationController!.view, animated: true)
            hud.mode = .indeterminate
            hud.label.text = "Clearing Data..."
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: {
                self.matchStore.clearMatchData(type)
                self.selectedMatch = nil
                DispatchQueue.main.async(execute: {
                    self.performSegue(withIdentifier: "SegueToInitialView", sender: self)
                    let hud = MBProgressHUD(for: self.navigationController!.view)
                    let imageView = UIImageView(image: UIImage(named: "Checkmark"))
                    hud?.customView = imageView
                    hud?.mode = .customView
                    hud?.label.text = "Completed"
                    self.tableView.reloadData()
                    hud?.hide(animated: true, afterDelay: 1)
                })
            })
        })
        ac.addAction(cancelAction)
        ac.addAction(continueAction)
        
        self.present(ac, animated: true, completion: nil)
    }
    
    func handleExport(_ sender:UIBarButtonItem) {
        let ac = UIAlertController(title: "Export Data", message: "", preferredStyle: .actionSheet)
        //let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let exportAll = UIAlertAction(title: "Export All Data", style: .default, handler: {(action) in
            // handle exporting all
            self.exportAllMatchData()
        })
        let exportNew = UIAlertAction(title: "Export New Data", style: .destructive, handler: {(action) in
            // Handle exporting New Data
            self.exportNewMatchData()
        })
        //ac.addAction(cancelAction)
        ac.addAction(exportAll)
        ac.addAction(exportNew)

        ac.popoverPresentationController?.barButtonItem = sender
        ac.popoverPresentationController?.sourceView = self.view
        
        ac.view.layoutIfNeeded()
        self.present(ac, animated: true, completion: nil)
    }
    
    func exportNewMatchData() {
        var temp = 0
        for m in matchStore.allMatches {
            if (m.isCompleted & 32) == 32 { temp += 1 }
        }
        if temp <= 0 {
            let ac = UIAlertController(title: "New Match Export Data", message: "There is no new match data, so no new data was written to the files", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            ac.addAction(okAction)
            self.present(ac, animated: true, completion: nil)
        } else {
            let ac = UIAlertController(title: "Export Data", message: "Are you sure you want to export data?  Doing so will overwrite previous data", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
            ac.addAction(cancelAction)
            
            let continueAction = UIAlertAction(title: "Yes", style: .default, handler: {(action) in
                let hud = MBProgressHUD.showAdded(to: self.navigationController!.view, animated: true)
                hud.mode = .indeterminate
                hud.label.text = "Exporting..."
                DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: {
                    _ = self.matchStore.exportNewMatchData(withType: PowerMatch.self)
                    DispatchQueue.main.async(execute: {
                        let hud = MBProgressHUD(for: self.navigationController!.view)
                        let imageView = UIImageView(image: UIImage(named: "Checkmark"))
                        hud?.customView = imageView
                        hud?.mode = .customView
                        hud?.label.text = "Completed"
                        self.tableView.reloadData()
                        hud?.hide(animated: true, afterDelay: 1)
                    })
                })
            })
            ac.addAction(continueAction)
            self.present(ac, animated: true, completion: nil)
        }
    }
    
    func exportAllMatchData() {
        let hud = MBProgressHUD.showAdded(to: self.navigationController!.view, animated: true)
        hud.mode = .indeterminate
        hud.label.text = "Exporting..."
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async(execute: {
            _ = self.matchStore.writeCSVFile(withType: PowerMatch.self)
            DispatchQueue.main.async(execute: {
                let hud = MBProgressHUD(for: self.navigationController!.view)
                let imageView = UIImageView(image: UIImage(named: "Checkmark"))
                hud?.customView = imageView
                hud?.mode = .customView
                hud?.label.text = "Completed"
                self.tableView.reloadData()
                hud?.hide(animated: true, afterDelay: 1)
            })
        })
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return matchStore.allMatches.count > 0 ? "Completed Matches"           : nil
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchStore.allMatches.count
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return matchStore.allMatches.count > 0 ? "\(matchStore.allMatches.count) Match(es)"     : nil
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MatchCell", for: indexPath) as! MatchCell

        let match = matchStore.allMatches[indexPath.row]
        cell.matchNumber.text = "\(match.matchNumber)"
        cell.teamNumber.text = "\(match.teamNumber)"
        
        cell.accessoryType = ((match.isCompleted & 32) != 32) ? .checkmark : .none

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let match = matchStore.removeMatchAtIndex(indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            if let mMatch = match as? MatchImpl, let sMatch = selectedMatch as? MatchImpl {
                if mMatch == sMatch {
                    self.performSegue(withIdentifier: "SegueToInitialView", sender: self)
                    selectedMatch = nil
                }
            }
            _ = matchStore.saveChanges(withMatchType: PowerMatch.self)
            self.tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedMatch = matchStore.allMatches[indexPath.row]
        performSegue(withIdentifier: "showMatchSummary", sender: self)
    }
}

extension MasterViewController: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        // TODO: Add Team Info View Controller
//        if let nc = popoverPresentationController.presentedViewController as? UINavigationController {
//            if let _ = nc.topViewController as? TeamInfoViewController {
//                MatchStore.sharedStore.cancelCurrentMatchEdit()
//            }
//        }
    }
}

